import os
import shutil
import subprocess
from argparse import ArgumentParser, Namespace
from pathlib import Path

from installman import confirm, confirm_dir, confirm_file, installer, path_exists

HERE = Path(__file__).parent
HOME = Path.home()
TPM_DIR = HOME / ".tmux" / "plugins" / "tpm"
TPM_URL = "https://github.com/tmux-plugins/tpm"


@installer("tmux", help="install tmux config with TPM (Tmux Plugin Manager)")
def install_tmux(args: Namespace):
    """Install tmux configuration with TPM setup."""
    tmux_config = HOME / ".tmux.conf"
    source_config = HERE / "tmux.conf"

    # Install TPM if not already installed
    if not args.no_tpm:
        install_tpm(tpm_dir=TPM_DIR, yes=args.yes)

    # Check if config already exists and handle it appropriately
    # Use confirm_file to handle existence check - returns True if file exists or user confirms creation
    # Set create=False to avoid creating empty file (we'll create symlink instead)
    config_exists = confirm_file(tmux_config, yes=args.yes, follow_symlinks=False, create=False)
    
    if not config_exists:
        # File doesn't exist, confirm if we should proceed
        if not confirm(yes=args.yes, prompt=f"Create tmux config at {tmux_config}? [y/N]: "):
            print("OK, aborting then :p")
            return

    # Handle existing config (symlink or regular file)
    if tmux_config.is_symlink():
        if tmux_config.resolve() == source_config:
            print(f"tmux config is already symlinked correctly")
            return
        else:
            print(f"Removing existing symlink pointing to {tmux_config.resolve()}")
            tmux_config.unlink()
    elif args.force and not tmux_config.is_symlink():
        backup = HOME / ".tmux.conf.bak"
        shutil.copy(tmux_config, backup)
        print(f"Backed up existing config to {backup}")
        tmux_config.unlink()
    elif not tmux_config.is_symlink():
        print(
            f"tmux config already exists at {tmux_config}. "
            "Use --force to replace it (backup will be created)"
        )
        return

    # Create symlink (if confirm_file created an empty file, remove it first)
    if tmux_config.is_file() and not tmux_config.is_symlink():
        tmux_config.unlink()
    
    if not tmux_config.is_symlink():
        tmux_config.symlink_to(source_config)
        print(f"tmux config symlinked from {source_config} to {tmux_config}")

    # Install TPM plugins if TPM is installed
    if not args.no_tpm and path_exists(TPM_DIR):
        if not args.no_plugins:
            print("\nInstalling tmux plugins...")
            print("You may need to press 'prefix + I' in tmux to install plugins manually")
            print("Or run: ~/.tmux/plugins/tpm/bin/install_plugins")
            # Try to install plugins automatically
            install_plugins_path = TPM_DIR / "bin" / "install_plugins"
            if path_exists(install_plugins_path):
                try:
                    subprocess.run([str(install_plugins_path)], check=False)
                except Exception as e:
                    print(f"Could not automatically install plugins: {e}")
                    print("Please run manually: ~/.tmux/plugins/tpm/bin/install_plugins")


def install_tpm(tpm_dir: Path, yes: bool = False) -> None:
    """Install TPM (Tmux Plugin Manager) if not already installed."""
    # Check if TPM is already installed using path_exists helper
    if path_exists(tpm_dir):
        print(f"TPM already installed at {tpm_dir}")
        return

    if not confirm(
        yes=yes,
        prompt=f"Install TPM to {tpm_dir}? [y/N]: ",
    ):
        print("Skipping TPM installation")
        return

    print(f"Installing TPM to {tpm_dir}...")
    # Ensure parent directory exists
    confirm_dir(tpm_dir.parent, yes=yes)

    try:
        subprocess.run(
            ["git", "clone", TPM_URL, str(tpm_dir)],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        print(f"TPM installed successfully at {tpm_dir}")
    except subprocess.CalledProcessError as e:
        print(f"Failed to install TPM: {e}")
        print(f"Please install manually: git clone {TPM_URL} {tpm_dir}")
    except FileNotFoundError:
        print("git not found. Please install git first or install TPM manually:")
        print(f"git clone {TPM_URL} {tpm_dir}")


@install_tmux.parser
def tmux_parser(parser: ArgumentParser):
    parser.add_argument(
        "--force",
        help="replace existing tmux config (creates backup)",
        action="store_true",
    )
    parser.add_argument(
        "--no-tpm",
        help="skip TPM installation",
        action="store_true",
    )
    parser.add_argument(
        "--no-plugins",
        help="skip plugin installation",
        action="store_true",
    )
    parser.add_argument(
        "--yes",
        help="automatically approve changes without prompting",
        action="store_true",
    )
