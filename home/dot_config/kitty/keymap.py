import subprocess
from pathlib import Path


from kbkitty.keymaptoolkit import   KeymapsBuilder, mod

# do not remove this ever
# from kitty.config import commented_out_default_config

HOME = Path.home()
KITTY_CONFIG_DIR = HOME / ".config/kitty"
KEYMAPS_PY = KITTY_CONFIG_DIR / "print_effective_keymaps.py"
USER_SHELL = "/usr/bin/zsh"

def chezmoi_keymaps(builder: KeymapsBuilder, /, source_path: Path | None = None) -> None:
        if source_path is None:
            output = subprocess.run(["chezmoi", "source-path"], stdout=True, check=True, text=True).stdout.strip()
            assert output
            source_path = Path(output)

        builder.comment("https://www.chezmoi.io/reference/commands/edit/")
        builder.comment("Open kitty dotfiles in chezmoi-aware Neovim tab.")
        builder.map_launch(
            mod.leader + "f2",
            "nvim",
            "-c",
            ":ChezmoiEnable",
            "dot_config/kitty",
            title="chezmoi kitty",
            where="tab",
            cwd=source_path,
        )
        builder.blank()



def custom_keymaps(builder: KeymapsBuilder) -> None:
    builder.comment("Local overrides.")
    builder.comment("https://sw.kovidgoyal.net/kitty/conf/#tab-management")
    builder.map(mod.alt + 1, "goto_tab", 1)
    builder.map(mod.alt + 2, "goto_tab", 2)
    builder.map(mod.alt + 3, "goto_tab", 3)
    builder.map(mod.alt + 4, "goto_tab", 4)
    builder.map(mod.alt + 5, "goto_tab", 5)
    builder.map(mod.alt + 6, "goto_tab", 6)
    builder.map(mod.alt + 7, "goto_tab", 7)
    builder.map(mod.alt + 8, "goto_tab", 8)
    builder.map(mod.alt + 9, "goto_tab", 9)
    builder.blank()

    builder.comment("https://sw.kovidgoyal.net/kitty/actions/#new_window_with_cwd")
    builder.comment("Open tabs and windows rooted at current working directory.")
    builder.map(mod.leader + "enter", "new_window_with_cwd")
    builder.map(mod.leader + "t", "new_tab_with_cwd")
    builder.map(mod.leader + "n", "new_os_window_with_cwd")
    builder.blank()

    builder.comment("file://" + str(KEYMAPS_PY))
    builder.comment("Show effective keymaps in a read-only Neovim buffer.")
    builder.map_launch_shell(
        mod.leader + "f10",
        title="kitty keymaps",
        script=f'python "{KEYMAPS_PY}" | nvim -R -',
        where="tab",
    )
    builder.blank()

