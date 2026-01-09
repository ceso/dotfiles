MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

THEME_URL = https://raw.githubusercontent.com/catppuccin/eza/refs/heads/main/themes/mocha/catppuccin-mocha-blue.yml


.PHONY: update
update: _theme.yml
	uv run --script merge.py


.PHONY: clean
clean:
	rm -f theme.yml _theme.yml


_theme.yml:
	curl -fsSL -o _theme.yml $(THEME_URL)
