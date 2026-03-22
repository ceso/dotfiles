#!/usr/bin/env -S uv run --script

# /// script
# requires-python = ">=3.14"
# dependencies = ["jsonyx"]
# ///

import logging
import os
import pathlib
import shutil
import subprocess
import sys
import typing

import jsonyx
import jsonyx.allow

logger = logging.getLogger(__name__)
DEBUG = "DEBUG" in os.environ

SHARED_SETTINGS_KEY = "workbench.settings.applyToAllProfiles"
IGNORED_SETTINGS = (SHARED_SETTINGS_KEY,)


def abort(*args: object) -> typing.NoReturn:
    logger.error(*args)
    sys.exit(1)


def get_vscode_dir() -> pathlib.Path:
    XDG_CONFIG_HOME = pathlib.Path(
        os.environ.get("XDG_CONFIG_HOME", "~/.config")
    )
    return (XDG_CONFIG_HOME / "Code" / "User").expanduser()


def get_vscode_exe() -> pathlib.Path:
    bin = shutil.which("code")
    if bin is None:
        abort("`code` command not found")
    return pathlib.Path(bin).resolve()


def json_load(jsonfile: pathlib.Path | str) -> typing.Any:
    with open(jsonfile) as fd:
        return jsonyx.load(
            fd, allow=jsonyx.allow.COMMENTS | jsonyx.allow.TRAILING_COMMA
        )


def run(*args: str) -> None:
    logger.debug("Executing: %r", args)
    process = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    if process.stdout:
        with process.stdout:
            for line in iter(process.stdout.readline, b""):
                logger.debug(line.decode().strip())

    if (exit_code := process.wait()) != 0:
        abort("Command %s failed with exit code %d", args, exit_code)


# cleanup profiles workspaces
# cleanup authorized folders
# cleanup authorized vendors
# cleanup authorized domains


def update_extensions(code: str, user: pathlib.Path) -> None:
    logger.info("Updating default profile ...")

    run(code, "--update-extensions")

    storage = json_load(user / "globalStorage" / "storage.json")
    for profile in storage.get("userDataProfiles", []):
        logger.info("Updating %s profile ...", profile["name"])
        run(code, "--profile", profile["name"], "--update-extensions")


def verify_shared_settings(user: pathlib.Path) -> None:
    logger.info("Verifying shared settings ...")
    settings = json_load(user / "settings.json")

    applied_settings = set(settings.get(SHARED_SETTINGS_KEY, []))
    if logging.DEBUG >= logging.root.level:
        logger.debug("Shared settings: %r", list(sorted(applied_settings)))

    defined_settings = set(
        setting
        for setting in settings.keys()
        if not setting.startswith("[") and setting not in IGNORED_SETTINGS
    )
    if logging.DEBUG >= logging.root.level:
        logger.debug("Defined settings: %r", list(sorted(defined_settings)))

    delta1 = applied_settings - defined_settings
    for key in delta1:
        logger.error("setting shared but not defined: %s", key)

    delta2 = defined_settings - applied_settings
    for key in delta2:
        logger.error("setting defined but not shared: %s", key)

    if delta1 or delta2:
        abort("configuration error")


def main() -> int:
    code = str(get_vscode_exe())
    user = get_vscode_dir()

    update_extensions(code, user)
    verify_shared_settings(user)

    return 0


if __name__ == "__main__":
    logging.basicConfig(
        format="%(relativeCreated)4d [%(levelname)s] %(message)s",
        level=logging.DEBUG if DEBUG else logging.INFO,
    )

    try:
        sys.exit(main())
    except KeyboardInterrupt:
        pass
    except Exception:
        logger.exception("Unhandled error. This is a bug.")
        sys.exit(2)
