# Reading containers resources usage from Linux

The Docker client provides a [`docker stats`](https://docs.docker.com/engine/reference/commandline/stats/) command to display system resources usage of running containers, such as CPU and memory usage:

```console
$ docker container stats
CONTAINER ID   NAME              CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O         PIDS
1552aca76806   aria2             0.03%     12.81MiB / 10.63GiB   0.12%     21.1GB / 933MB    168MB / 13.3MB    2
```

The Docker client requests the statistics from the [Docker Engine API](https://docs.docker.com/engine/api/latest/) and its [`/containers/{id}/stats`](https://docs.docker.com/engine/api/v1.43/#tag/Container/operation/ContainerStats) endpoint. It is possible to query this API directly to inspect what the client receives from the engine:

```console
$ curl --unix-socket /var/run/docker.sock 'http:/v1.43/containers/1552aca76806/stats?stream=false&one-shot=true'
```
```json
{
	"read": "2023-10-03T19:09:13.842221932Z",
	"preread": "0001-01-01T00:00:00Z",
	"pids_stats": {
		"current": 2,
		"limit": 13014
	},
	"blkio_stats": {
		"io_service_bytes_recursive": [
			{
				"major": 8,
				"minor": 16,
				"op": "read",
				"value": 155594752
			},
			{
				"major": 8,
				"minor": 16,
				"op": "write",
				"value": 0
			},
			{
				"major": 8,
				"minor": 0,
				"op": "read",
				"value": 12849152
			},
			{
				"major": 8,
				"minor": 0,
				"op": "write",
				"value": 13348864
			}
		],
		"io_serviced_recursive": null,
		"io_queue_recursive": null,
		"io_service_time_recursive": null,
		"io_wait_time_recursive": null,
		"io_merged_recursive": null,
		"io_time_recursive": null,
		"sectors_recursive": null
	},
	"num_procs": 0,
	"storage_stats": {},
	"cpu_stats": {
		"cpu_usage": {
			"total_usage": 3955663822000,
			"usage_in_kernelmode": 1861115782000,
			"usage_in_usermode": 2094548040000
		},
		"system_cpu_usage": 8303217570000000,
		"online_cpus": 4,
		"throttling_data": {
			"periods": 0,
			"throttled_periods": 0,
			"throttled_time": 0
		}
	},
	"precpu_stats": {
		"cpu_usage": {
			"total_usage": 0,
			"usage_in_kernelmode": 0,
			"usage_in_usermode": 0
		},
		"throttling_data": {
			"periods": 0,
			"throttled_periods": 0,
			"throttled_time": 0
		}
	},
	"memory_stats": {
		"usage": 20103168,
		"stats": {
			"active_anon": 8192,
			"active_file": 5144576,
			"anon": 7581696,
			"anon_thp": 2097152,
			"file": 11812864,
			"file_dirty": 0,
			"file_mapped": 7053312,
			"file_writeback": 0,
			"inactive_anon": 7573504,
			"inactive_file": 6668288,
			"kernel_stack": 32768,
			"pgactivate": 627,
			"pgdeactivate": 2,
			"pgfault": 376813,
			"pglazyfree": 0,
			"pglazyfreed": 0,
			"pgmajfault": 104,
			"pgrefill": 17,
			"pgscan": 827,
			"pgsteal": 258,
			"shmem": 0,
			"slab": 515208,
			"slab_reclaimable": 333824,
			"slab_unreclaimable": 181384,
			"sock": 4096,
			"thp_collapse_alloc": 20,
			"thp_fault_alloc": 1,
			"unevictable": 0,
			"workingset_activate": 0,
			"workingset_nodereclaim": 0,
			"workingset_refault": 0
		},
		"limit": 11413270528
	},
	"name": "/aria2",
	"id": "1552aca7680656f0647952f0be64e5e23d3493aac833b734aadf09aa0e941d58",
	"networks": {
		"eth0": {
			"rx_bytes": 21084946999,
			"rx_packets": 11396493,
			"rx_errors": 0,
			"rx_dropped": 0,
			"tx_bytes": 933300257,
			"tx_packets": 7510670,
			"tx_errors": 0,
			"tx_dropped": 0
		}
	}
}
```
<style>pre { max-height: 36em }</style>

But where is the Docker Engine itself getting these statistics from?

In this post, we are going to see how these values can be obtained by the kernel directly.

## Starting point

The first place to start getting some information about the container is the [cgroup](https://docs.kernel.org/admin-guide/cgroup-v2.html) Docker created for it (generally cgroup v2 in particular nowadays).

In the case of Docker installed via its `apt` repository on Debian 12, container cgroups can be listed at this path:

```console
$ ls -d /sys/fs/cgroup/system.slice/docker-*.scope
/sys/fs/cgroup/system.slice/docker-1552aca7680656f0647952f0be64e5e23d3493aac833b734aadf09aa0e941d58.scope
/sys/fs/cgroup/system.slice/docker-102978d670fb958f6f412680cf10901072bbd2901bd35fecd2691e52afd96cda.scope
/sys/fs/cgroup/system.slice/docker-19bd38ec4f94b6842ab9459c417a866f764771dedeae925c666981d7c92adb45.scope
```

Each cgroup listed under the pseudo filesystem available on`/sys/fs/cgroup` also provide different kinds of statistics via the same filesystem interface.

Let's pick container `1552aca76806` and extract some info from it.

## CPU

The CPU percentage shown by `docker stats` is calculated by comparing how many milliseconds the processes inside the cgroup runs in either user or system mode on the CPU over time. This means that two observations at different times are required to calculate a percentage.

The cgroup exposes this value in a `cpu.stat` file:

```console
$ cd /sys/fs/cgroup/system.slice/docker-1552aca7680656f0647952f0be64e5e23d3493aac833b734aadf09aa0e941d58.scope
$ cat cpu.stat
usage_usec 3956133964
user_usec 2094773011
system_usec 1861360953
nr_periods 0
nr_throttled 0
throttled_usec 0
nr_bursts 0
burst_usec 0
```

We can take the `user_usec` and `system_usec` values and sum them to obtain a value of 3,956,133,964 microseconds. We wait for example 1 second and repeat the reading. If the difference between the readings 1,000,000, then the container was using 100% of the CPU. If 500,000, then 50% of the CPU. If 2,000,000, then 200% (multiple cores).

With that, we replicated the "`CPU %`" column of `docker stats`.

(From simple observations, `usage_usec` seems to equal to `user_usec + system_usec`, but I'm not sure whether that's always the case. The source of this value is [`struct task_cputime`](https://elixir.bootlin.com/linux/latest/C/ident/task_cputime).)

With this method, we are not that precise because reading the value exactly 1 second apart is virtually impossible. [Docker actually compares the deltas of CPU time of the container with overall CPU system time](https://github.com/docker/docker-ce/blob/6bb4de18c8cdca6916074d7a0be640e27c689202/components/cli/cli/command/container/stats_helpers.go#L166-L183). This is might be more accurate is most scenarios, but it also is not entirely precise since the readings of container and system values are not made at the same time.

## Memory

For memory, statistics are also surfaced via the same interface. However, [some portion of the memory (`inactive_file`) is excluded by Docker](https://github.com/docker/docker-ce/blob/6bb4de18c8cdca6916074d7a0be640e27c689202/components/cli/cli/command/container/stats_helpers.go#L245-L246).

```console
$ cd /sys/fs/cgroup/system.slice/docker-1552aca7680656f0647952f0be64e5e23d3493aac833b734aadf09aa0e941d58.scope

$ cat memory.current
20054016
$ memory_current=$(!!)

$ grep inactive_file memory.stat
inactive_file 6627328
$ inactive_file=$(!! | cut -d' ' -f2)

$ echo $(( memory_current - inactive_file ))
13426688
```

The last value is the number of bytes Docker considers the container is consuming of memory, the "`MEM USAGE`" column.

The container can be created with an [upper memory limit](https://docs.docker.com/config/containers/resource_constraints/). If that's the case, the file `memory.max` will contain a number (bytes):

```console
$ cat memory.max
134217728
```

If no limit was set at container creation, the file contains the word "`max`" and the system memory is generally considered the limit:

```console
$ cat memory.max
max

$ grep MemTotal /proc/meminfo
MemTotal:       11145772 kB
```

Both the "`MEM LIMIT`" and "`MEM %`" columns are calculated from either the container limit (when set), or the total system memory.

## Network

Network statistics are available through [procfs](https://docs.kernel.org/filesystems/proc.html#networking-info-in-proc-net) instead of directly from the cgroup.

To read the network statistics from procfs, we need to fetch the PID of the first process of the container and read its `net/dev`:

```console
$ cd /sys/fs/cgroup/system.slice/docker-1552aca7680656f0647952f0be64e5e23d3493aac833b734aadf09aa0e941d58.scope
$ head -1 cgroup.threads 
2128
$ pid=$(!!)

$ cat /proc/$pid/net/dev
Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
    lo:   18943     242    0    0    0     0          0         0    18943     242    0    0    0     0       0          0
  eth0: 21088035122 11415345    0    0    0     0          0         0 936801118 7534896    0    0    0     0       0          0
```

Even though it's not perfectly visually aligned, we need to sum up the values of all interfaces for "Receive bytes" and "Transmit bytes" individually.

In this case, the value of the "`NET I/O`" column would be:

- input/receive: 18943 + 21088035122 bytes and
- output/transmit: 18943 + 936801118 bytes.

If the container uses different [types of networks](https://docs.docker.com/engine/reference/commandline/network_create/) than the default "bridge", such as `--network=host`, it is not possible to retrieve network statistics for the container. `docker stats` also shows "`0B / 0B`" in this case.

## Block Devices I/O

Block devices I/O statistics are separate by device in `io.stat`:

```console
$ cd /sys/fs/cgroup/system.slice/docker-1552aca7680656f0647952f0be64e5e23d3493aac833b734aadf09aa0e941d58.scope
$ cat io.stat
8:16 rbytes=155594752 wbytes=0 rios=465 wios=0 dbytes=0 dios=0
8:0 rbytes=12849152 wbytes=13398016 rios=221 wios=1101 dbytes=0 dios=0
```

Here, the `rbytes` and `wbytes` can be taken. To get to the values of the "`BLOCK I/O`" column, summing all devices in this case would be:

- input/read: 155594752 + 12849152 bytes and
- output/write: 0 + 13398016 bytes.

## PIDs

The number of threads is conveniently available in the `pids.current`:

```console
$ cd /sys/fs/cgroup/system.slice/docker-1552aca7680656f0647952f0be64e5e23d3493aac833b734aadf09aa0e941d58.scope
$ cat pids.current
2
```

That is the "`PIDS`" column.
