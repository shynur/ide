SHELL := /bin/bash -O globstar

.PHONY: push
push:
	$(MAKE) git-push
	$(MAKE) build
	docker push shynur/ide

.PHONY: build
build: Dockerfile	
	docker build -t shynur/ide .

.PHONY: git-push
git-push:
	git add .
	git commit -m ';'
	git push
