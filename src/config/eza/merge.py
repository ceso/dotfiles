#!/usr/bin/env -S uv run --script

# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "deepmerge==2.0",
#     "ruamel.yaml==0.18.16",
#     "pyyaml==6.0.3",
# ]
# ///

from deepmerge import always_merger
from ruamel.yaml import YAML

yaml = YAML(typ="safe", pure=True)

with open("_theme.yml", mode="rb") as fd:
    theme = yaml.load(fd)

with open("_local.yml", mode="rb") as fd:
    local = yaml.load(fd)

always_merger.merge(theme, local)

with open("theme.yml", mode="wb") as fd:
    yaml.dump(theme, fd)
