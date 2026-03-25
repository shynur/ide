SHELL := /bin/bash -O globstar

all: FORCE

%/:
	mkdir -p $@
	-chmod -R a+rwx $@

image/VERSION: FORCE | image/
	git rev-parse HEAD >|$@

git-push: FORCE
	git add .
	git commit -m ';'
	git push

.PHONY: FORCE
FORCE:
