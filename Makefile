SHELL = /bin/bash -O globstar

export CFLAGS = $(shell echo "$$CFLAGS")
export CXXFLAGS = -Wpedantic -Wall -W $(shell echo "$$CXXFLAGS")

.PHONY: all
all:

.PHONY: clean
clean:
	rm -f   ./**/?*~   ./**/.?*~   ./**/\#?*\#   ./**/.\#?*
	rm -rf  bin
	rm -f  ./**/?*.el[cn]
	rm -f  ./**/?*.{so,dylib,dll}

%/:
	mkdir -p $@
	-chmod -R a+rwx $@

FORCE:

git-push: FORCE
	git pull
	git add .
	GIT_EDITOR=`[ -f /snap/bin/emacs ] && echo /snap/bin/emacs || which emacs &>/dev/null && echo emacs` git commit -v
	git push
