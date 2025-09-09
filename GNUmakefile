MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules


.PHONY: all
all: check install


.PHONY: clean
clean:
	git clean -fdx


.PHONY: install
install:
	bash install.sh


.PHONY: check
check:
	shellcheck --enable=all --shell=bash -x src/bin/*.sh
	shfmt --indent 4 --diff src/bin/*.sh
