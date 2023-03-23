serve: image
	docker container run \
		--rm \
		--name $(notdir $(CURDIR)) \
		--volume $(CURDIR):/data:ro \
		--workdir /data \
		--publish 4000:4000 \
		--entrypoint jekyll \
		github-pages \
		serve --destination=/tmp/_site --host=

image:
	docker image inspect github-pages >/dev/null 2>&1 || \
	docker image build \
		--no-cache \
		--tag github-pages \
		https://github.com/actions/jekyll-build-pages.git#main

clean:
	-docker image rm github-pages
