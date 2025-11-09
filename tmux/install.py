import subprocess
from argparse import ArgumentParser, Namespace
from pathlib import Path

from fencing import CodeFence, copy_block
from installman import (
    confirm,
    confirm_brewed,
    confirm_dir,
    confirm_symlink,
    installer,
    path_exists,
)

HERE = Path(__file__).parent
HOME = Path.home()
TPM_DIR = HOME / ".tmux" / "plugins" / "tpm"
TPM_URL = "https://github.com/tmux-plugins/tpm"


@installer("tmux", help="install tmux config with TPM (Tmux Plugin Manager)")
def install_tmux(args: Namespace):
    """Install tmux configuration with TPM setup."""
    tmux_config = HOME / ".tmux.conf"
    source_config = HERE / "tmux.conf"

    # Install tmux if not already installed
    tmux_path = confirm_brewed("tmux", yes=args.yes)
    if not tmux_path:
        print(
            "tmux not available. Install tmux first or use --yes to install automatically."
        )
        return

    # Install TPM if not already installed
    if not args.no_tpm:
        install_tpm(tpm_dir=TPM_DIR, yes=args.yes)

    # Use confirm_symlink helper to handle symlink creation
    if not confirm_symlink(
        source=source_config,
        destination=tmux_config,
        yes=args.yes,
        backup=True,
    ):
        print("OK, aborting then :p")
        return

    # Install TPM plugins if TPM is installed
    if not args.no_tpm and path_exists(TPM_DIR):
        if not args.no_plugins:
            print("\nInstalling tmux plugins...")
            print(
                "You may need to press 'prefix + I' in tmux to install plugins manually"
            )
            print("Or run: ~/.tmux/plugins/tpm/bin/install_plugins")
            # Try to install plugins automatically
            install_plugins_path = TPM_DIR / "bin" / "install_plugins"
            if path_exists(install_plugins_path):
                try:
                    subprocess.run([str(install_plugins_path)], check=False)
                except Exception as e:
                    print(f"Could not automatically install plugins: {e}")
                    print(
                        "Please run manually: ~/.tmux/plugins/tpm/bin/install_plugins"
                    )

    _, new, changed = copy_block(
        CodeFence.symettric("### TMUX Functions ###"),
        HERE / "shell_functions.sh",
        (HOME / ".zshrc").read_text(),
        replace=True,
    )

    if changed:
        print("Addding shell functions...")
        (HOME / ".zshrc").write_text(new)
    else:
        print("Shell functions are already added in the .zshrc")


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
    except FileNotFoundError:
        print("git not found. Please install git first or install TPM manually:")
        print(f"git clone {TPM_URL} {tpm_dir}")

    except Exception as e:
        print(f"Failed to install TPM: {e}")
        print(f"Please install manually: git clone {TPM_URL} {tpm_dir}")


@install_tmux.parser
def tmux_parser(parser: ArgumentParser):
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
