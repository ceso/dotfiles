#!/usr/bin/env python3

import sys
import pathlib
import subprocess
import re
import typing

SELF = pathlib.Path(__file__)


def abort(message: str, *, status: int) -> typing.NoReturn:
    sys.stderr.write(message)
    sys.exit(status)


def pkgutil(*args: str) -> subprocess.CompletedProcess[str]:
    command = ["pkgutil"] + list(args)
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        message = f"ERROR: {command!r} => {result.returncode}\n{result.stderr}"
        abort(message, status=2)
    return result


def getinfo(tag: str, pkginfo: str) -> str:
    if m := re.search(rf"^{tag}: (.*)", pkginfo, re.MULTILINE):
        return m.group(1)
    else:
        abort(f"ERROR: pattern failed: {tag!r}\n{pkginfo}", status=3)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        abort("Usage: {SELF.name} <package-id>", status=1)
    package = sys.argv[1]

    result = pkgutil("--pkg-info", package)
    volume = getinfo("volume", result.stdout)
    location = getinfo("location", result.stdout)
    base = pathlib.Path(volume) / location

    try:
        result = pkgutil("--only-files", "--files", package)
        for pkgfile in result.stdout.splitlines():
            (base / pkgfile).unlink(missing_ok=True)

        result = pkgutil("--only-dirs", "--files", package)
        for pkgdir in sorted(result.stdout.splitlines(), reverse=True):
            d = base / pkgdir
            if d.exists():
                d.rmdir()

        pkgutil("--forget", package)
    except OSError as exc:
        abort(f"ERROR: {exc!r}, {exc.filename!r}", status=4)
