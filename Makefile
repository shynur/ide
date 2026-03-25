SHELL := /bin/bash -O globstar

.PHONY: all
all:

%/:
	mkdir -p $@
	-chmod -R a+rwx $@

.PHONY: git-push
git-push:
	git add .
	git commit -m ';'
	git push
