#!/usr/bin/env python3
import os
import sys
from pathlib import Path
from typing import Any

HOME = Path(os.environ["HOME"])
sys.path.insert(0, "/usr/lib/kitty")

from kitty.config import load_config  # type: ignore
from kitty.types import Shortcut  # type: ignore


CONFIG_PATH = Path(os.environ.get("KITTY_KEYMAP_CONFIG", HOME / ".config/kitty/kitty.conf"))


def mode_name(name: str) -> str:
    return name or "normal"


def key_sort_key(item: tuple[Any, Any]) -> tuple[int, int, bool]:
    trigger = item[0]
    return trigger.mods, trigger.key, trigger.is_native


def format_definition(definition: Any) -> str:
    return definition.human_repr()


def main() -> int:
    opts = load_config(str(CONFIG_PATH))
    print(f"# kitty config: {CONFIG_PATH}")
    print("# effective keymaps")
    print("# first action shown below each key is winner")
    print()
    for keyboard_mode_name, keyboard_mode in sorted(opts.keyboard_modes.items(), key=lambda item: item[0]):
        print(f"## mode: {mode_name(keyboard_mode_name)}")
        print()
        for trigger, definitions in sorted(keyboard_mode.keymap.items(), key=key_sort_key):
            actions = [format_definition(definition) for definition in definitions]
            effective = actions[-1]
            print(f"{Shortcut((trigger,)).human_repr(opts.kitty_mod):<24} -> {effective}")
            if len(actions) > 1:
                overridden = actions[:-1]
                print(f"{'':<24}    overridden:")
                for action in overridden:
                    print(f"{'':<24}      {action}")
            print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
