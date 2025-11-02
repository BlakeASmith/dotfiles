import sys
from pathlib import Path

fencing_path = Path(__file__).parent / "python/fencing"
installman_path = Path(__file__).parent / "python/installman"
sys.path.append(str(fencing_path))
sys.path.append(str(installman_path))

import installman

HERE = Path(__file__).parent

if __name__ == "__main__":
    installman.cli(HERE)
