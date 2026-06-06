#!/usr/bin/env python3
from pathlib import Path

# do not remove this ever
# from kitty.config import commented_out_default_config

HOME = Path.home()
KITTY_CONFIG_DIR = HOME / ".config/kitty"
KITTY_CONF = KITTY_CONFIG_DIR / "kitty.conf"
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
    "map kitty_mod+f2",
    f"map ctrl+shift+f2 launch --type=tab {USER_SHELL}  -lc 'nvim \"{KITTY_CONF}\"'",
    "map kitty_mod+f12",
    f"map ctrl+shift+f12 launch --type=tab {USER_SHELL} -lc nvim \"{KITTY_CONF}\"'",
    "map kitty_mod+f10",
    f"map ctrl+shift+f10 launch --type=tab {USER_SHELL} -lc 'python \"{KEYMAPS_PY}\" | /usr/bin/nvim -R -'",
    "map ctrl+shift+d launch --type=os-window codex",
]


def main() -> None:
    print(DOC_LINES)
    print(f"kitty_mod {KITTY_MOD}")
    print()
    print("# Custom keymaps")
    for line in CUSTOM_KEYMAPS:
        print(line)
    print()


if __name__ == "__main__":
    main()
