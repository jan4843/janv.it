# Storing Postgres container databases as files for easier backups

In [my servers setup](https://github.com/jan4843/infrastructure), each service gets its own directory in `/opt` with a Docker Compose file. Static configuration files go in `/opt/$SERVICE/config`. When a services produces some data it needs to maintain its state, that is also stored in `/opt/$SERVICE/data`. This way, each service is encapsulated and can, for example, be moved to another host simply by moving its directory (and a `docker compose up`). More importantly, services can easily be backed up.

Most services I deploy (like [changedetection.io](https://changedetection.io), [TVHeadend](https://tvheadend.org)), use flat files to serialize and store their state. I purposefully try to avoid services that need much state, and often refrain from deploying a service when a database management system is required, or I use SQLite if possible.

When choosing my current feed reader to self-host, however, I decided to go with [Miniflux](https://miniflux.app), which works only with Postgres. To still make the service portable and easy to back up, I came up with this setup:

- every time the backing Postgres container is stopped (and additionally, on a schedule), it dumps its databases into a `dump.sql.gz` file,
- when the Postgres service is started afresh, it automatically restores from `dump.sql.gz`.

## The Setup

First, the `compose.yaml` (or equivalent) file has to be adapted, so that the `postgres` service has with the following keys:

- `volumes`,
- `entrypoint`,
- `stop_signal`,
- `stop_grace_period`,
- `healthcheck`.

```yaml
services:
  miniflux:
    image: miniflux/miniflux:2.0.43
    environment:
      DATABASE_URL: postgres://miniflux:internal@postgres/miniflux?sslmode=disable
      RUN_MIGRATIONS: 1
      CREATE_ADMIN: 1
      ADMIN_USERNAME: admin
      ADMIN_PASSWORD: miniflux
    restart: unless-stopped

  postgres:
    image: postgres:15.1-alpine
    environment:
      POSTGRES_USER: miniflux
      POSTGRES_PASSWORD: internal
    volumes:
      - ./data:/docker-entrypoint-initdb.d
      - ./utils:/utils:ro
    entrypoint: /utils/entrypoint
    stop_signal: SIGTERM
    stop_grace_period: 5m
    healthcheck:
      test: [CMD, /utils/dump]
      start_period: 3m
      interval: 1h
    restart: unless-stopped
```

Notice how the usual `/var/lib/postgresql/data` is not mounted in the container.

Then, two executables have to be created in the `./utils` directory of the host, next to the `compose.yaml` file.

An executable `./utils/dump` invokes [`pg_dump`](https://www.postgresql.org/docs/current/app-pgdump.html) and unconditionally exits successfully:

```shell
#!/bin/sh

pg_dump --username="$POSTGRES_USER" --file=/docker-entrypoint-initdb.d/dump.sql.gz --compress=9
exit 0
```

An executable `./utils/entrypoint` sets up a signal handler to be run before the container is stopped, and then invokes the original `postgres` entrypoint:

```shell
#!/bin/sh

DUMP_PATH=$(dirname "$0")/dump

on_exit() {
	"$DUMP_PATH"

	kill -SIGTERM "$POSTGRES_PID"
	wait "$POSTGRES_PID"

	exit 143
}

trap on_exit SIGTERM

/usr/local/bin/docker-entrypoint.sh postgres "$@" &
POSTGRES_PID=$!

tail -f /dev/null &
wait $!
```

## Explanation

When the Postgres container is created, any file in `/docker-entrypoint-initdb.d` (such as our `dump.sql.gz`) is automatically executed, as explained in [documentation for the official `postgres` Docker image](https://hub.docker.com/_/postgres).  
(If the container is restarted and a database already exists, it will ignore the initialization directory and continue to use its existing storage and continue from where it left off.)

When the container is stopped, the overridden entrypoint will invoke the `dump` script which generates `/docker-entrypoint-initdb.d/dump.sql.gz` (from the container perspective) aka `./data/dump.sq.gz` (host perspective).

Finally, the container healthcheck is misused to run a job on a schedule. In this case, it is configured to:

- create a scheduled dump every hour,
- not create scheduled dumps within the first 3 minutes of the each container start,
- when stopping the container, wait up to 5 minutes for a dump to finish before letting the container engine forcefully kill the container.

The scheduled dump via healthcheck is performed so that in case of abrupt termination of the container (such as a power loss), where the signal handler defined in the overriden entrypoint doesn't have a chance to run, a relatively up-to-date dump is still available.  
Such a job can alternatively be set with `cron` on the host, for example, to avoid misusing the healthcheck functionality.

This setup is appropriate only for small databases, since the regular dumping of Postgres might get expensive, time- and CPU-wise, with bigger databases. Moreover, the reliability of the dump running is not guaranteed, so I would be conscious relying the setup for important data. However, it is always possible to check the `dump.sql.gz` creation date to be reassured before proceeding with a `docker compose down`.
