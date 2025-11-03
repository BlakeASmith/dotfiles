"""
installman - utilities for writing standaolone installation scripts that combine
    into a person dotfile management CLI
"""

import difflib
import importlib.util
import os
import shutil
import sys

# pyright: reportPrivateUsage=false
# pyright: reportAny=false,reportExplicitAny=false
# pyright: reportUnknownParameterType=false
# pyright: reportUnknownArgumentType=false
# pyright: reportMissingParameterType=false
from argparse import ArgumentParser, Namespace, _SubParsersAction
from pathlib import Path
from tracemalloc import start
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


def dependency(str):
    # routing through here in case we need logic later
    # For example, to get things that would exist but not be on the PATH yet
    return shutil.which(str)


@final
class SingleFileChange:
    def __init__(self, before: str | None, after: str, path: Path) -> None:
        if self.before is None:
            self.before = ""
        # assuming there is some content
        # not handling the case there isn't, so better to fail loudly
        assert self.after
        self.before = before
        self.after = after
        self.path = path

    def apply(self):
        _ = self.path.write_text(self.after)

    def diff(self, contextlines=2):
        assert self.before is not None
        _diff = difflib.unified_diff(
            self.before.splitlines(keepends=True),
            self.after.splitlines(keepends=True),
            fromfile=str(self.path),
            tofile=str(self.path),
            n=contextlines,
        )
        return "".join(_diff)

    def confirm(
        self,
        yes=False,
        prompt="Apply this change? [y/N]: ",
        onapplied=lambda: print("Applied!"),
        onabort=lambda: print("Skipped!"),
    ):
        print(f"Changes to {self.path}:")
        print(self.diff())

        global confirm
        if confirm(yes=yes, prompt=prompt):
            self.apply()
            onapplied()
        else:
            onabort()


def confirm(
    *,
    yes=False,
    prompt="Apply this change? [y/N]: ",
):
    if yes:
        return True

    response = input(prompt).strip().lower()
    if response.startswith("y"):
        return True
    else:
        return False


def confirm_dir(
    path: Path, *, yes=False, prompt=None, mode=511, parents=True, follow_symlinks=True
):
    if path.exists(follow_symlinks=follow_symlinks):
        return True

    if prompt is None:
        prompt = f"{path} does not exist, should we create it now? (y/N): "

    if confirm(yes=yes, prompt=prompt):
        path.mkdir(mode=mode, parents=parents)
        return True

    return False


def path_exists(path: Path, *, follow_symlinks: bool = True) -> bool:
    """Check if a path exists without creating it."""
    return path.exists(follow_symlinks=follow_symlinks)


def confirm_symlink(
    source: Path,
    destination: Path,
    *,
    yes: bool = False,
    backup: bool = True,
) -> bool:
    """Confirm and create a symlink from source to destination.
    
    Args:
        source: The file/directory to symlink to (must exist)
        destination: Where to create the symlink
        yes: Automatically approve without prompting (replaces existing files/directories)
        backup: If True and replacing existing file, create backup before replacing
        
    Returns:
        True if symlink was created or already exists correctly, False if user declined
    """
    # Check if source exists
    if not source.exists():
        raise FileNotFoundError(f"Source path does not exist: {source}")
    
    # Check if symlink already exists and points to correct target
    if destination.is_symlink():
        try:
            if destination.resolve() == source.resolve():
                return True
        except (OSError, RuntimeError):
            # Symlink is broken, we'll replace it
            pass
    
    # Handle existing file/directory
    if path_exists(destination):
        if destination.is_symlink():
            # Different symlink, ask to replace it
            if not yes:
                if not confirm(
                    yes=yes,
                    prompt=f"Symlink at {destination} points to {destination.resolve()}, "
                    f"replace with {source}? [y/N]: ",
                ):
                    return False
            destination.unlink()
        elif yes:
            # Regular file/directory, replace automatically if yes=True
            if backup and destination.is_file():
                backup_path = destination.with_suffix(destination.suffix + ".bak")
                shutil.copy(destination, backup_path)
                print(f"Backed up existing file to {backup_path}")
            elif backup and destination.is_dir():
                backup_path = destination.with_name(destination.name + ".bak")
                shutil.copytree(destination, backup_path)
                print(f"Backed up existing directory to {backup_path}")
            if destination.is_file() or destination.is_dir():
                if destination.is_dir():
                    shutil.rmtree(destination)
                else:
                    destination.unlink()
        else:
            # Regular file/directory exists, ask to replace it
            if not confirm(
                yes=yes,
                prompt=f"{destination} already exists. Replace it? [y/N]: ",
            ):
                return False
            # User confirmed, proceed with replacement
            if backup and destination.is_file():
                backup_path = destination.with_suffix(destination.suffix + ".bak")
                shutil.copy(destination, backup_path)
                print(f"Backed up existing file to {backup_path}")
            elif backup and destination.is_dir():
                backup_path = destination.with_name(destination.name + ".bak")
                shutil.copytree(destination, backup_path)
                print(f"Backed up existing directory to {backup_path}")
            if destination.is_file() or destination.is_dir():
                if destination.is_dir():
                    shutil.rmtree(destination)
                else:
                    destination.unlink()
    
    # Confirm creation if not yes and file doesn't exist
    if not yes and not path_exists(destination):
        if not confirm(
            yes=yes,
            prompt=f"Create symlink from {destination} to {source}? [y/N]: ",
        ):
            return False
    
    # Ensure parent directory exists
    confirm_dir(destination.parent, yes=yes)
    
    # Create the symlink
    try:
        destination.symlink_to(source)
        print(f"Symlinked {destination} -> {source}")
        return True
    except OSError as e:
        print(f"Failed to create symlink: {e}")
        return False


type Change = SingleFileChange


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
        dest="subcommand", help="Availible Installers:"
    )

    for installer in installers:
        subparser = installer._setup_subparser(subparsers)
        installer._setup_parser(subparser)

    args = root_parser.parse_args()
    if args.subcommand is None:
        root_parser.print_help()
        exit(1)
    {installer.name: installer.install for installer in installers}[args.subcommand](
        args
    )
