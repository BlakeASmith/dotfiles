import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).parent
fencing_path = HERE / "python/fencing"
installman_path = HERE / "python/installman"


def ensure_module_installed(module_path: Path, module_name: str) -> None:
    """Idempotently ensure a module is installed via pip install.
    
    This is idempotent because pip install -e will skip installation if the
    package is already installed in editable mode from the same path.
    """
    subprocess.check_call(
        [sys.executable, "-m", "pip", "install", "-e", str(module_path)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


if __name__ == "__main__":
    # Ensure dependencies are installed before importing
    ensure_module_installed(fencing_path, "fencing")
    ensure_module_installed(installman_path, "installman")

    # Add paths to sys.path as fallback for local development
    sys.path.insert(0, str(fencing_path))
    sys.path.insert(0, str(installman_path))

    import installman

    installman.cli(HERE)
