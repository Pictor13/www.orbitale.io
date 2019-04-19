JEKYLL_VERSION         = 3.8
serve: stop
	@docker run --name=orbitale.io \
		--detach \
		-v `pwd`:/srv/jekyll \
		-v `pwd`/vendor/bundle:/usr/local/bundle \
		--publish=4000:4000 \
		jekyll/jekyll:$(JEKYLL_VERSION) \
		jekyll serve --watch \
		>/dev/null
	@echo "Listening to http://127.0.0.1:4000"

stop:
	-@docker rm -f orbitale.io >/dev/null 2>&1
