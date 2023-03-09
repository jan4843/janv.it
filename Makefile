RUBY_VERSION = $(shell curl -fs https://pages.github.com/versions.json | sed -E 's/.*"ruby":\s*"([^"]+).*/\1/')
IMAGE := github-pages

.SILENT:

serve: image
	docker container run \
		--rm \
		--name $(notdir $(CURDIR)) \
		--volume $(CURDIR):/data:ro \
		--publish 4000:4000 \
		$(IMAGE)

image:
	docker image inspect $(IMAGE) >/dev/null 2>&1 || \
	docker image build \
		--no-cache \
		--tag $(IMAGE) \
		--build-arg RUBY_VERSION=$(RUBY_VERSION) \
		.

clean:
	$(RM) -r _site Gemfile.lock
	-docker image rm $(IMAGE)
