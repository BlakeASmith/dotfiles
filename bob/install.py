#!/usr/bin/env python3
from os import system
from shutil import which

bob = which("bob")
cargo = which("cargo")

if not bob:
    if not cargo:
        print("I need cargo to install bob --- install rust first")
    system("cargo install --git https://github.com/MordechaiHadad/bob.git")

system("~/.cargo/bin/bob install nightly")
system("~/.cargo/bin/bob install v0.11.4")
system("~/.cargo/bin/bob use v0.11.4")
