from argparse import ArgumentParser, Namespace
from pathlib import Path

from installman import installer

HERE = Path(__file__).parent.parent
HOME = Path.home()


@installer(
    "bin",
    help="pick scripts from the bin to install. use 'all' to grab everything",
)
def install_bin(args: Namespace):
    target_bin = Path("~/.local/bin").expanduser()
    source_bin = HERE / "bin"

    if args.config[0] == "all":
        scripts = source_bin.glob("*")
    else:
        scripts = [source_bin / script for script in args.config]

    for source in scripts:
        if source.is_file():
            (target_bin / source.name).symlink_to(source)
            print(f"symlinked {source} to {target_bin / source.name}")


@install_bin.parser
def setup_bin_args(parser: ArgumentParser):
    bin_choices = ["all"] + [
        p.name
        for p in (HERE / "bin").glob("*")
        if p.is_file() and p.name != "install.py"
    ]
    parser.add_argument(
        "config",
        nargs="+",
        choices=bin_choices,
    )
