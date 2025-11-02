import os
from argparse import ArgumentParser, Namespace
from pathlib import Path

from installman import Subparsers, installer, symlink_rec

HERE = Path(__file__).parent
HOME = Path.home()


@installer("nvim", help="install neovim config, or parts of it")
def install_nvim(args: Namespace):
    if args.mode == "all":
        nvim_path = HOME / ".config/nvim"
        all_path = HERE
        if args.symlink_dir:
            nvim_path.symlink_to(all_path)
            print(f"symlinked entire nvim config to {nvim_path}")
            return

        symlink_rec(all_path, nvim_path, quiet=False)
        return

    if args.mode == "selective":

        if not args.plugin:
            print("set --plugin option. Nothing else here yet")
            return

        if args.plugin:
            plugins_path = HOME / ".config/nvim/lua/plugins"
            plugin_install_path = plugins_path / f"{args.plugin}.lua"
            plugin_impl_path = HERE / f"lua/plugins/{args.plugin}.lua"

            plugin_install_path.symlink_to(plugin_impl_path)
            print(f"created symlink from {plugin_impl_path} to {plugin_install_path}")
            return

    if args.mode == "pip":
        os.system("pip install pynvim==0.6.0")


@install_nvim.parser
def nvim_parser(parser: ArgumentParser):
    _ = parser.add_argument("--plugin", choices=["tfling"], default=None)
    _ = parser.add_argument(
        "--symlink-dir", default=None, action="store_true", help="don't use this"
    )
    _ = parser.add_argument(
        "mode", default="selective", choices=["selective", "all", "pip"]
    )
