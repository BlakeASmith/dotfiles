import os
import shutil
import subprocess
from argparse import ArgumentParser, Namespace
from contextlib import suppress
from pathlib import Path

from installman import dependency, installer

HERE = Path(__file__).parent
HOME = Path.home()


@installer("lazygit", aliases=["lg"], help="setup lazygit with config file linked")
def install_lazygit(args: Namespace):
    if not args.no_install:
        brew = dependency("brew")
        os.system(f"{brew} install lazygit")

    # lazygit config direcotry will be in a differnet place depending on how it was installed
    # there is a -ucf option which allows changing it, but we can also just get the current one
    output = subprocess.check_output(["lazygit", "--print-config-dir"])
    target = Path(output.decode().strip()) / "config.yml"
    source = HERE / "config.yml"
    target.parent.mkdir(parents=True, exist_ok=True)
    try:
        target.symlink_to(source)
    except FileExistsError:
        if args.force and not target.is_symlink():
            shutil.copy(target, target.parent / "config.yml.bak")
            print(f"copied existing config to {str(target)}.bak")
            target.unlink()
            target.symlink_to(source)

    print(f"lazygit config file is symlinked from {source} to {target}")


@install_lazygit.parser
def lazygit_parser(parser: ArgumentParser):
    # no options yet
    parser.add_argument(
        "--force",
        help="symlink the config file even if there is an existing one",
        action="store_true",
    )
    parser.add_argument(
        "--no-install", help="skip brew install of lazygit", action="store_true"
    )
