SHELL := /bin/bash -O globstar

.PHONY: build
build: Dockerfile
	git add .
	git commit -m ';'
	git push
	docker build -t shynur/dev-env-cpp .
