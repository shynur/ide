SHELL := /bin/bash -O globstar

.PHONY: git-push
git-push:
	git add .
	git commit -m ';'
	git push
