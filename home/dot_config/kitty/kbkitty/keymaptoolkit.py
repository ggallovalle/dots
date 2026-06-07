
from typing import override, Literal
from pathlib import Path
import shlex

LaunchType = Literal["tab", "window"]
LauncCwd = Path | Literal["current", "last_reported", "oldest", "root"]

class KeymapsBuilder:
    _mappings: list[str]
    _opt_shell: str
    _opt_launch_where: None | LaunchType
    _opt_launch_cwd: None | LauncCwd

    def __init__(self, *, shell:str = "zsh -lc", launch_where: None | LaunchType = None, launch_cwd: None | LauncCwd = None) -> None:
        self._mappings = []
        self._opt_shell = shell
        self._opt_launch_where = launch_where
        self._opt_launch_cwd = launch_cwd

    def map(self, keymap: str, action: str, /, *args: str, **kwargs: str) -> None:
        flags = " ".join(f'--{key}="{value}"' for key, value in kwargs.items())
        line = f"map {keymap} {action} {flags} {' '.join(args)}"
        self._mappings.append(line)

    def map_launch_shell(self, keymap: str, /, 
                   title: str,
                   script: str,
                   where: None | LaunchType = None,
                   cwd: None | LauncCwd=None,
                   ) -> None:

        self.map_launch(keymap, self._opt_shell, shlex.quote(script), title=title, where=where, cwd=cwd, )

    def map_launch(self, keymap: str, program: str, /,  *args: str,
                   title: str,
                   where: None | LaunchType = None,
                   cwd: None | LauncCwd=None,
                   ) -> None:
        flags: dict[str, str] = {"title": title}

        where = where or self._opt_launch_where
        cwd = cwd or self._opt_launch_cwd
        if where is not None:
            flags["type"] = where
        if where is not None:
            flags["cwd"] = str(cwd)
        
        self.map(keymap, "launch", program, *args, **flags)

    @override
    def __str__(self) -> str:
        return "\n".join(self._mappings)

