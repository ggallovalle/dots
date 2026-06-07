#!/usr/bin/env python3
import os
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

from kbkitty.keymaptoolkit import KeymapsBuilder

# do not remove this ever
# from kitty.config import commented_out_default_config


class ChezmoiActions:
    source_path: Path

    def __init__(self, /, source_path: Path | None = None) -> None:
        if source_path is None:
            output = subprocess.run(["chezmoi", "source-path"], stdout=True, check=True).stdout
            assert len(output) > 0
            source_path = Path(str(output))
        self.source_path = source_path

    def keymaps(self) -> KeymapsBuilder:
        builder = KeymapsBuilder(launch_cwd=self.source_path, launch_where="tab")
        target = os.path.join("dot_config", "kitty")
        builder.map_launch("ctrl+shift+f2", "nvim", "-c", ":ChezmoiEnable", target, title="chezmoi kitty")
        return builder
        # return [f"""map ctrl+shift+f2 launch --type=tab --cwd={self.source_path} --title="chezmoi kitty" {self.edit_dot_config("kitty")} """]

HOME = Path.home()
KITTY_CONFIG_DIR = HOME / ".config/kitty"
KEYMAPS_PY = KITTY_CONFIG_DIR / "print_effective_keymaps.py"
KITTY_MOD = "ctrl+shift"
USER_SHELL = "/usr/bin/zsh"

DOC_LINES = """
# Kitty keyboard mapping docs:",
# https://sw.kovidgoyal.net/kitty/mapping/",
# Default shortcut reference:",
# https://sw.kovidgoyal.net/kitty/conf/#keyboard-shortcuts",
#",
# kitty_mod is shorthand used by kitty's default shortcuts.
# Default value is ctrl+shift, so set it explicitly here for clarity.
# Modifiers kitty understands in keymaps: ctrl, shift, alt, super.
"""

CUSTOM_KEYMAPS: list[str] = [
    "map alt+1 goto_tab 1",
    "map alt+2 goto_tab 2",
    "map alt+3 goto_tab 3",
    "map alt+4 goto_tab 4",
    "map alt+5 goto_tab 5",
    "map alt+6 goto_tab 6",
    "map alt+7 goto_tab 7",
    "map alt+8 goto_tab 8",
    "map alt+9 goto_tab 9",
    "map kitty_mod+enter new_window_with_cwd",
    "map kitty_mod+t new_tab_with_cwd",
    "map kitty_mod+n new_os_window_with_cwd",
    "map kitty_mod+f10",
    f"""map ctrl+shift+f10 launch --type=tab --title "kitty keymaps" {USER_SHELL} -lc 'python "{KEYMAPS_PY}" | nvim -R -' """,
]


def main() -> None:
    print(DOC_LINES)
    print(f"kitty_mod {KITTY_MOD}")
    print()
    print("# Custom keymaps")
    for line in CUSTOM_KEYMAPS:
        print(line)

    chezmoi = ChezmoiActions(source_path=HOME / "dots/home")
    print(chezmoi.keymaps())
    print()


if __name__ == "__main__":
    main()
