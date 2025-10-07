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
	shellcheck src/bin/*.sh
	shfmt --diff src/bin/*.sh
