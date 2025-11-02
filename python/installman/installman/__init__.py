"""
installman - utilities for writing standaolone installation scripts that combine
    into a person dotfile management CLI
"""

import importlib.util
import os
import sys

# pyright: reportPrivateUsage=false
# pyright: reportAny=false,reportExplicitAny=false
# pyright: reportUnknownParameterType=false
# pyright: reportUnknownArgumentType=false
# pyright: reportMissingParameterType=false
from argparse import ArgumentParser, Namespace, _SubParsersAction
from pathlib import Path
from typing import Any, Callable, final

type Subparsers = _SubParsersAction[ArgumentParser]


@final
class Installer:
    def __init__(
        self,
        name: str,
        install: Callable[[Namespace], None],
        _subparser_args: dict[str, Any] | None = None,
        _setup_subparser: Callable[[Subparsers], ArgumentParser] | None = None,
        _setup_parser: Callable[[ArgumentParser], None] | None = None,
    ) -> None:
        self.name = name
        self.install = install
        if _setup_subparser is None:
            _subparser_args = _subparser_args or {}

            def _default_subparser(subparsers: Subparsers):
                return subparsers.add_parser(name=name, **_subparser_args)

            _setup_subparser = _default_subparser

        self._setup_subparser = _setup_subparser

        if _setup_parser is None:

            def _default_parser(
                parser: ArgumentParser,  # pyright: ignore[reportUnusedParameter]
            ):
                return None

            _setup_parser = _default_parser

        self._setup_parser = _setup_parser

    def parser(self, f: Callable[[ArgumentParser], None]):
        self._setup_parser = f
        return f


def installer(name: str, **kwargs):
    """
    Decorator for creating an install subcommand. Kwargs are passed to argparse
    add_subparsers function.
    """

    def _installer(f: Callable[[Namespace], None]):
        return Installer(name=name, install=f, _subparser_args=kwargs)

    return _installer


def symlink_rec(source: Path, destination: Path, quiet: bool = False):
    """Recursively symlink all leaf files from source to destination.

    Creates directory structure in destination as needed, but only symlinks
    individual files, not directories.
    """
    if not destination.exists():
        destination.mkdir()

    if not source.is_dir() or not destination.is_dir():
        raise ValueError(f"{source} or {destination} is not a directory")

    for item in source.rglob("*"):
        if item.is_file():
            rel = item.relative_to(source)
            dest = destination / rel
            dest.parent.mkdir(parents=True, exist_ok=True)
            try:
                dest.symlink_to(item)
            except:
                if not quiet:
                    print(
                        f"- failed to symlink {item} to {dest} (probably already exists)"
                    )

            if not quiet:
                print(f"- symlinked {item} to {dest}")


def __import_and_get_installers(module_path):
    """
    Dynamically imports a module from a file path and returns all global
    instances of a specified class defined within that module.
    """
    module_name = os.path.splitext(os.path.basename(module_path))[0]

    # 1. Dynamically import the module
    spec = importlib.util.spec_from_file_location(module_name, module_path)
    if spec is None:
        raise ImportError(f"Could not find module spec for {module_path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    assert spec.loader is not None
    spec.loader.exec_module(module)

    # 3. Find and return all instances of that class
    instances = []
    for name in dir(module):
        attribute = getattr(module, name)
        # Check if the attribute is an instance of the target class
        if isinstance(attribute, Installer):
            instances.append(attribute)

    return instances


def cli(root: Path | str, *args, **kwargs):
    if isinstance(root, str):
        root = Path(root)
    install_scripts = root.expanduser().rglob("install.py")

    installers = []
    for script in install_scripts:
        installers.extend(__import_and_get_installers(script))

    root_parser = ArgumentParser(*args, **kwargs)
    subparsers = root_parser.add_subparsers(
        dest="subcommand", help="Availible Installers:", required=True
    )

    for installer in installers:
        subparser = installer._setup_subparser(subparsers)
        installer._setup_parser(subparser)

    args = root_parser.parse_args()
    {installer.name: installer.install for installer in installers}[args.subcommand](
        args
    )
