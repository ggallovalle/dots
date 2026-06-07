from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass
from pathlib import Path
import shlex
from typing import Final, Literal, final, overload, override

LaunchType = Literal["tab", "window"]
LauncCwd = Path | Literal["current", "last_reported", "oldest", "root"]
MapOptions = Mapping[str, str]


@dataclass(frozen=True, slots=True)
class Key:
    value: str

    def __init__(self, value: str | int, /) -> None:
        object.__setattr__(self, "value", str(value))

    @classmethod
    def coerce(cls, value: Key | str | int, /) -> Key:
        if isinstance(value, Key):
            return value
        return cls(value)

    @override
    def __str__(self) -> str:
        return self.value


@dataclass(frozen=True, slots=True)
class Keymap:
    modifiers: tuple[str, ...]
    key: Key

    @staticmethod
    def bare(value: Key | str | int, /) -> Keymap:
        return Keymap((), Key.coerce(value))

    @staticmethod
    def coerce(value: Keymap | KeySequence | str, /) -> str:
        return str(value)

    def then(self, other: Keymap | Key | str | int, /) -> KeySequence:
        return KeySequence((self, _coerce_stroke(other)))

    def __gt__(self, other: Keymap | Key | str | int, /) -> KeySequence:
        return self.then(other)

    @override
    def __str__(self) -> str:
        if len(self.modifiers) == 0:
            return str(self.key)
        return "+".join((*self.modifiers, str(self.key)))


@dataclass(frozen=True, slots=True)
class KeySequence:
    strokes: tuple[Keymap, ...]

    def then(self, other: Keymap | Key | str | int, /) -> KeySequence:
        return KeySequence((*self.strokes, _coerce_stroke(other)))

    def __gt__(self, other: Keymap | Key | str | int, /) -> KeySequence:
        return self.then(other)

    @override
    def __str__(self) -> str:
        return ">".join(str(stroke) for stroke in self.strokes)


def _coerce_stroke(value: Keymap | Key | str | int, /) -> Keymap:
    if isinstance(value, Keymap):
        return value
    return Keymap.bare(value)


@dataclass(frozen=True, slots=True)
class KeyModifier:
    modifiers: tuple[str, ...]

    @overload
    def __add__(self, other: KeyModifier, /) -> KeyModifier: ...

    @overload
    def __add__(self, other: Key | str | int, /) -> Keymap: ...

    def __add__(self, other: KeyModifier | Key | str | int, /) -> KeyModifier | Keymap:
        if isinstance(other, KeyModifier):
            return KeyModifier((*self.modifiers, *other.modifiers))
        return Keymap(self.modifiers, Key.coerce(other))

    @override
    def __str__(self) -> str:
        return "+".join(self.modifiers)


@final
class _ModifierNamespace:
    leader: Final[KeyModifier] = KeyModifier(("kitty_mod",))
    ctrl: Final[KeyModifier] = KeyModifier(("ctrl",))
    shift: Final[KeyModifier] = KeyModifier(("shift",))
    alt: Final[KeyModifier] = KeyModifier(("alt",))
    super: Final[KeyModifier] = KeyModifier(("super",))
    cmd: Final[KeyModifier] = KeyModifier(("cmd",))
    opt: Final[KeyModifier] = KeyModifier(("opt",))
    option: Final[KeyModifier] = KeyModifier(("option",))


mod: Final = _ModifierNamespace()


class KeymapsBuilder:
    _lines: list[str]
    _opt_shell: str
    _opt_launch_where: None | LaunchType
    _opt_launch_cwd: None | LauncCwd

    def __init__(self, *, shell: str = "zsh -lc", launch_where: None | LaunchType = None, launch_cwd: None | LauncCwd = None) -> None:
        self._lines = []
        self._opt_shell = shell
        self._opt_launch_where = launch_where
        self._opt_launch_cwd = launch_cwd

    def raw(self, line: str, /) -> None:
        self._lines.append(line)

    def blank(self) -> None:
        self._lines.append("")

    def comment(self, text: str = "") -> None:
        if text:
            self._lines.append(f"# {text}")
            return
        self._lines.append("#")

    def setting(self, name: str, value: str, /) -> None:
        self._lines.append(f"{name} {value}")

    def unmap(self, keymap: Keymap | KeySequence | str, /, *, map_options: None | MapOptions = None) -> None:
        parts = ["map", *self._map_options(map_options), Keymap.coerce(keymap)]
        self._lines.append(" ".join(parts))

    def map(
        self,
        keymap: Keymap | KeySequence | str,
        action: str,
        /,
        *args: object,
        map_options: None | MapOptions = None,
        **kwargs: object,
    ) -> None:
        parts = ["map", *self._map_options(map_options), Keymap.coerce(keymap), action]
        parts.extend(f'--{key}="{value}"' for key, value in kwargs.items())
        parts.extend(str(x) for x in args)
        self._lines.append(" ".join(parts))

    def map_launch_shell(
        self,
        keymap: Keymap | KeySequence | str,
        /,
        title: str,
        script: str,
        where: None | LaunchType = None,
        cwd: None | LauncCwd = None,
    ) -> None:
        self.map_launch(keymap, self._opt_shell, shlex.quote(script), title=title, where=where, cwd=cwd)

    def map_launch(
        self,
        keymap: Keymap | KeySequence | str,
        program: str,
        /,
        *args: str,
        title: str,
        where: None | LaunchType = None,
        cwd: None | LauncCwd = None,
    ) -> None:
        flags: dict[str, str] = {"title": title}

        where = where or self._opt_launch_where
        cwd = cwd or self._opt_launch_cwd
        if where is not None:
            flags["type"] = where
        if cwd is not None:
            flags["cwd"] = str(cwd)

        self.map(keymap, "launch", program, *args, map_options=None, **flags)

    def _map_options(self, map_options: None | MapOptions, /) -> list[str]:
        if map_options is None:
            return []
        return [f"--{key}={value}" for key, value in map_options.items()]

    @override
    def __str__(self) -> str:
        return "\n".join(self._lines)

