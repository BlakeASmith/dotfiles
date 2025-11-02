#!/usr/bin/env python3
import sys
from argparse import ArgumentParser, Namespace
from os import system
from pathlib import Path
from shutil import which

HERE_PARENT = Path(__file__).parent.parent
installman_path = HERE_PARENT / "python/installman"
sys.path.append(str(installman_path))

from installman import dependency, installer


@installer("bob", help="install bob (neovim version manager)")
def install_bob(args: Namespace):
    bob = which("bob")
    cargo = which("cargo")

    if not bob:
        if not cargo:
            print("I need cargo to install bob --- install rust first")
            return
        system("cargo install --git https://github.com/MordechaiHadad/bob.git")

    bob_path = bob or "~/.cargo/bin/bob"
    system(f"{bob_path} install nightly")
    system(f"{bob_path} install v0.11.4")
    system(f"{bob_path} use v0.11.4")


@install_bob.parser
def setup_bob_args(parser: ArgumentParser):
    pass
