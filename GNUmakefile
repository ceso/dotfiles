MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

SHELL_SCRIPTS = src/bin/*.sh


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
	shellcheck $(SHELL_SCRIPTS)
	shfmt --diff $(SHELL_SCRIPTS)
