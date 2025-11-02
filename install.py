import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).parent


def ensure_module_installed() -> None:
    """Idempotently ensure a module is installed via pip install.

    This is idempotent because pip install -e will skip installation if the
    package is already installed in editable mode from the same path.
    """
    try:
        import fencing
    except ModuleNotFoundError:
        subprocess.run(
            [sys.executable, "-m", "pip", "install", str(HERE / "python/fenching")]
        )

    try:
        import installman
    except ModuleNotFoundError:
        subprocess.run(
            [sys.executable, "-m", "pip", "install", str(HERE / "python/installman")]
        )


if __name__ == "__main__":
    ensure_module_installed()

    import installman

    installman.cli(HERE)
