import os
import shutil
import subprocess
from argparse import ArgumentParser, Namespace
from pathlib import Path

from installman import confirm, confirm_dir, installer

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

    # Handle existing config
    if tmux_config.exists():
        if tmux_config.is_symlink():
            if tmux_config.resolve() == source_config:
                print(f"tmux config is already symlinked correctly")
                return
            else:
                print(f"Removing existing symlink pointing to {tmux_config.resolve()}")
                tmux_config.unlink()
        elif args.force:
            backup = HOME / ".tmux.conf.bak"
            shutil.copy(tmux_config, backup)
            print(f"Backed up existing config to {backup}")
            tmux_config.unlink()
        else:
            print(
                f"tmux config already exists at {tmux_config}. "
                "Use --force to replace it (backup will be created)"
            )
            return

    # Create symlink
    tmux_config.symlink_to(source_config)
    print(f"tmux config symlinked from {source_config} to {tmux_config}")

    # Install TPM plugins if TPM is installed
    if not args.no_tpm and TPM_DIR.exists():
        if not args.no_plugins:
            print("\nInstalling tmux plugins...")
            print("You may need to press 'prefix + I' in tmux to install plugins manually")
            print("Or run: ~/.tmux/plugins/tpm/bin/install_plugins")
            # Try to install plugins automatically
            install_plugins_path = TPM_DIR / "bin" / "install_plugins"
            if install_plugins_path.exists():
                try:
                    subprocess.run([str(install_plugins_path)], check=False)
                except Exception as e:
                    print(f"Could not automatically install plugins: {e}")
                    print("Please run manually: ~/.tmux/plugins/tpm/bin/install_plugins")


def install_tpm(tpm_dir: Path, yes: bool = False) -> None:
    """Install TPM (Tmux Plugin Manager) if not already installed."""
    if tpm_dir.exists():
        print(f"TPM already installed at {tpm_dir}")
        return

    if not confirm(
        yes=yes,
        prompt=f"Install TPM to {tpm_dir}? [y/N]: ",
    ):
        print("Skipping TPM installation")
        return

    print(f"Installing TPM to {tpm_dir}...")
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
