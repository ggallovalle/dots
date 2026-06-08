
from dataclasses import dataclass
from typing import Final


from kbkitty.keymaptoolkit import KeySequence, Keymap, KeymapsBuilder, MapOptions, mod

ALLOW_FALLBACK: Final[dict[str, str]] = {"allow-fallback": "shifted,ascii"}
KEYBOARD_SHORTCUTS_DOC: Final = "https://sw.kovidgoyal.net/kitty/conf/#keyboard-shortcuts"
SECTION_DOCS: Final[dict[str, str]] = {
    "clipboard": "https://sw.kovidgoyal.net/kitty/conf/#clipboard",
    "scrolling": "https://sw.kovidgoyal.net/kitty/conf/#scrolling",
    "window-management": "https://sw.kovidgoyal.net/kitty/conf/#window-management",
    "tab-management": "https://sw.kovidgoyal.net/kitty/conf/#tab-management",
    "layout-management": "https://sw.kovidgoyal.net/kitty/conf/#layout-management",
    "font-sizes": "https://sw.kovidgoyal.net/kitty/conf/#font-sizes",
    "visible-text": "https://sw.kovidgoyal.net/kitty/conf/#select-and-act-on-visible-text",
    "miscellaneous": "https://sw.kovidgoyal.net/kitty/conf/#miscellaneous",
}
SPECIAL_DOCS: Final[dict[tuple[str, str], str]] = {
    ("kitten", "hints"): "https://sw.kovidgoyal.net/kitty/kittens/hints/",
    ("kitten", "choose-files"): "https://sw.kovidgoyal.net/kitty/kittens/choose-files/",
    ("kitten", "unicode_input"): "https://sw.kovidgoyal.net/kitty/kittens/unicode_input/",
    ("command_palette", ""): "https://sw.kovidgoyal.net/kitty/kittens/command-palette/",
    ("show_kitty_doc", ""): "https://sw.kovidgoyal.net/kitty/overview/",
}

@dataclass(frozen=True, slots=True)
class DocumentedShortcut:
    section: str
    description: str
    keymap: Keymap | KeySequence
    action: str
    args: tuple[str, ...] = ()
    map_options: None | MapOptions = None

    @property
    def docs_link(self) -> str:
        hint = self.args[0] if self.action == "kitten" and len(self.args) > 0 else ""
        return SPECIAL_DOCS.get((self.action, hint), SPECIAL_DOCS.get((self.action, ""), SECTION_DOCS[self.section]))


def shortcut(
    section: str,
    description: str,
    keymap: Keymap | KeySequence,
    action: str,
    *args: str,
    allow_fallback: bool = False,
) -> DocumentedShortcut:
    return DocumentedShortcut(
        section=section,
        description=description,
        keymap=keymap,
        action=action,
        args=args,
        map_options=ALLOW_FALLBACK if allow_fallback else None,
    )

def kitty_defaults(builder: KeymapsBuilder) -> None:

    DEFAULT_SHORTCUTS: Final[tuple[DocumentedShortcut, ...]] = (
    shortcut("clipboard", "Copy to clipboard.", mod.leader + "c", "copy_to_clipboard", allow_fallback=True),
    shortcut("clipboard", "Copy to clipboard or pass key through.", mod.cmd + "c", "copy_or_noop", allow_fallback=True),
    shortcut("clipboard", "Paste from clipboard.", mod.leader + "v", "paste_from_clipboard", allow_fallback=True),
    shortcut("clipboard", "Paste from clipboard.", mod.cmd + "v", "paste_from_clipboard", allow_fallback=True),
    shortcut("clipboard", "Paste from selection.", mod.leader + "s", "paste_from_selection", allow_fallback=True),
    shortcut("clipboard", "Paste from selection.", mod.shift + "insert", "paste_from_selection"),
    shortcut("clipboard", "Pass selection to open program.", mod.leader + "o", "pass_selection_to_program", allow_fallback=True),
    shortcut("scrolling", "Scroll one line up.", mod.leader + "up", "scroll_line_up", "smooth"),
    shortcut("scrolling", "Scroll one line up.", mod.leader + "k", "scroll_line_up", "smooth", allow_fallback=True),
    shortcut("scrolling", "Scroll one line up.", mod.opt + mod.cmd + "page_up", "scroll_line_up", "smooth"),
    shortcut("scrolling", "Scroll one line up.", mod.cmd + "up", "scroll_line_up", "smooth"),
    shortcut("scrolling", "Scroll one line down.", mod.leader + "down", "scroll_line_down", "smooth"),
    shortcut("scrolling", "Scroll one line down.", mod.leader + "j", "scroll_line_down", "smooth", allow_fallback=True),
    shortcut("scrolling", "Scroll one line down.", mod.opt + mod.cmd + "page_down", "scroll_line_down", "smooth"),
    shortcut("scrolling", "Scroll one line down.", mod.cmd + "down", "scroll_line_down", "smooth"),
    shortcut("scrolling", "Scroll one page up.", mod.leader + "page_up", "scroll_page_up"),
    shortcut("scrolling", "Scroll one page up.", mod.cmd + "page_up", "scroll_page_up"),
    shortcut("scrolling", "Scroll one page down.", mod.leader + "page_down", "scroll_page_down"),
    shortcut("scrolling", "Scroll one page down.", mod.cmd + "page_down", "scroll_page_down"),
    shortcut("scrolling", "Scroll to top of scrollback.", mod.leader + "home", "scroll_home"),
    shortcut("scrolling", "Scroll to top of scrollback.", mod.cmd + "home", "scroll_home"),
    shortcut("scrolling", "Scroll to bottom of scrollback.", mod.leader + "end", "scroll_end"),
    shortcut("scrolling", "Scroll to bottom of scrollback.", mod.cmd + "end", "scroll_end"),
    shortcut("scrolling", "Jump to previous shell prompt.", mod.leader + "z", "scroll_to_prompt", "-1", allow_fallback=True),
    shortcut("scrolling", "Jump to next shell prompt.", mod.leader + "x", "scroll_to_prompt", "1", allow_fallback=True),
    shortcut("scrolling", "Open scrollback buffer in pager.", mod.leader + "h", "show_scrollback", allow_fallback=True),
    shortcut("scrolling", "Open last shell command output in pager.", mod.leader + "g", "show_last_command_output", allow_fallback=True),
    shortcut("scrolling", "Search scrollback in pager.", mod.leader + "/", "search_scrollback"),
    shortcut("scrolling", "Search scrollback in pager.", mod.cmd + "f", "search_scrollback", allow_fallback=True),
    shortcut("window-management", "Create new window.", mod.leader + "enter", "new_window"),
    shortcut("window-management", "Create new window.", mod.cmd + "enter", "new_window"),
    shortcut("window-management", "Create new OS window.", mod.leader + "n", "new_os_window", allow_fallback=True),
    shortcut("window-management", "Create new OS window.", mod.cmd + "n", "new_os_window", allow_fallback=True),
    shortcut("window-management", "Close current window.", mod.leader + "w", "close_window", allow_fallback=True),
    shortcut("window-management", "Close current window.", mod.shift + mod.cmd + "d", "close_window", allow_fallback=True),
    shortcut("window-management", "Focus next window.", mod.leader + "]", "next_window"),
    shortcut("window-management", "Focus previous window.", mod.leader + "[", "previous_window"),
    shortcut("window-management", "Move window forward.", mod.leader + "f", "move_window_forward", allow_fallback=True),
    shortcut("window-management", "Move window backward.", mod.leader + "b", "move_window_backward", allow_fallback=True),
    shortcut("window-management", "Move window to top.", mod.leader + "`", "move_window_to_top"),
    shortcut("window-management", "Start interactive window resize.", mod.leader + "r", "start_resizing_window", allow_fallback=True),
    shortcut("window-management", "Start interactive window resize.", mod.cmd + "r", "start_resizing_window", allow_fallback=True),
    shortcut("window-management", "Focus first window.", mod.leader + 1, "first_window"),
    shortcut("window-management", "Focus first window.", mod.cmd + 1, "first_window"),
    shortcut("window-management", "Focus second window.", mod.leader + 2, "second_window"),
    shortcut("window-management", "Focus second window.", mod.cmd + 2, "second_window"),
    shortcut("window-management", "Focus third window.", mod.leader + 3, "third_window"),
    shortcut("window-management", "Focus third window.", mod.cmd + 3, "third_window"),
    shortcut("window-management", "Focus fourth window.", mod.leader + 4, "fourth_window"),
    shortcut("window-management", "Focus fourth window.", mod.cmd + 4, "fourth_window"),
    shortcut("window-management", "Focus fifth window.", mod.leader + 5, "fifth_window"),
    shortcut("window-management", "Focus fifth window.", mod.cmd + 5, "fifth_window"),
    shortcut("window-management", "Focus sixth window.", mod.leader + 6, "sixth_window"),
    shortcut("window-management", "Focus sixth window.", mod.cmd + 6, "sixth_window"),
    shortcut("window-management", "Focus seventh window.", mod.leader + 7, "seventh_window"),
    shortcut("window-management", "Focus seventh window.", mod.cmd + 7, "seventh_window"),
    shortcut("window-management", "Focus eighth window.", mod.leader + 8, "eighth_window"),
    shortcut("window-management", "Focus eighth window.", mod.cmd + 8, "eighth_window"),
    shortcut("window-management", "Focus ninth window.", mod.leader + 9, "ninth_window"),
    shortcut("window-management", "Focus ninth window.", mod.cmd + 9, "ninth_window"),
    shortcut("window-management", "Focus tenth window.", mod.leader + 0, "tenth_window"),
    shortcut("window-management", "Visually focus window.", mod.leader + "f7", "focus_visible_window"),
    shortcut("window-management", "Visually swap with another window.", mod.leader + "f8", "swap_with_window"),
    shortcut("tab-management", "Focus next tab.", mod.leader + "right", "next_tab"),
    shortcut("tab-management", "Focus next tab.", mod.shift + mod.cmd + "]", "next_tab"),
    shortcut("tab-management", "Focus next tab.", mod.ctrl + "tab", "next_tab"),
    shortcut("tab-management", "Focus previous tab.", mod.leader + "left", "previous_tab"),
    shortcut("tab-management", "Focus previous tab.", mod.shift + mod.cmd + "[", "previous_tab"),
    shortcut("tab-management", "Focus previous tab.", mod.ctrl + mod.shift + "tab", "previous_tab"),
    shortcut("tab-management", "Create new tab.", mod.leader + "t", "new_tab", allow_fallback=True),
    shortcut("tab-management", "Create new tab.", mod.cmd + "t", "new_tab", allow_fallback=True),
    shortcut("tab-management", "Close current tab.", mod.leader + "q", "close_tab", allow_fallback=True),
    shortcut("tab-management", "Close current tab.", mod.cmd + "w", "close_tab", allow_fallback=True),
    shortcut("tab-management", "Close OS window.", mod.shift + mod.cmd + "w", "close_os_window", allow_fallback=True),
    shortcut("tab-management", "Move tab forward.", mod.leader + ".", "move_tab_forward"),
    shortcut("tab-management", "Move tab backward.", mod.leader + ",", "move_tab_backward"),
    shortcut("tab-management", "Set tab title.", mod.leader + mod.alt + "t", "set_tab_title", allow_fallback=True),
    shortcut("tab-management", "Set tab title.", mod.shift + mod.cmd + "i", "set_tab_title", allow_fallback=True),
    shortcut("layout-management", "Switch to next layout.", mod.leader + "l", "next_layout", allow_fallback=True),
    shortcut("font-sizes", "Increase font size everywhere.", mod.leader + "equal", "change_font_size", "all", "+2.0"),
    shortcut("font-sizes", "Increase font size everywhere.", mod.leader + "plus", "change_font_size", "all", "+2.0"),
    shortcut("font-sizes", "Increase font size everywhere.", mod.leader + "kp_add", "change_font_size", "all", "+2.0"),
    shortcut("font-sizes", "Increase font size everywhere.", mod.cmd + "plus", "change_font_size", "all", "+2.0"),
    shortcut("font-sizes", "Increase font size everywhere.", mod.cmd + "equal", "change_font_size", "all", "+2.0"),
    shortcut("font-sizes", "Increase font size everywhere.", mod.shift + mod.cmd + "equal", "change_font_size", "all", "+2.0"),
    shortcut("font-sizes", "Decrease font size everywhere.", mod.leader + "minus", "change_font_size", "all", "-2.0"),
    shortcut("font-sizes", "Decrease font size everywhere.", mod.leader + "kp_subtract", "change_font_size", "all", "-2.0"),
    shortcut("font-sizes", "Decrease font size everywhere.", mod.cmd + "minus", "change_font_size", "all", "-2.0"),
    shortcut("font-sizes", "Decrease font size everywhere.", mod.shift + mod.cmd + "minus", "change_font_size", "all", "-2.0"),
    shortcut("font-sizes", "Reset font size everywhere.", mod.leader + "backspace", "change_font_size", "all", "0"),
    shortcut("font-sizes", "Reset font size everywhere.", mod.cmd + 0, "change_font_size", "all", "0"),
    shortcut("visible-text", "Open visible URL with hints.", mod.leader + "e", "open_url_with_hints", allow_fallback=True),
    shortcut("visible-text", "Insert selected path into terminal.", (mod.leader + "p") > "f", "kitten", "hints", "--type", "path", "--program", "-", allow_fallback=True),
    shortcut("visible-text", "Open selected path.", (mod.leader + "p") > (mod.shift + "f"), "kitten", "hints", "--type", "path", allow_fallback=True),
    shortcut("visible-text", "Insert chosen file.", (mod.leader + "p") > "c", "kitten", "choose-files", allow_fallback=True),
    shortcut("visible-text", "Insert chosen directory.", (mod.leader + "p") > "d", "kitten", "choose-files", "--mode=dir", allow_fallback=True),
    shortcut("visible-text", "Insert selected line.", (mod.leader + "p") > "l", "kitten", "hints", "--type", "line", "--program", "-", allow_fallback=True),
    shortcut("visible-text", "Insert selected word.", (mod.leader + "p") > "w", "kitten", "hints", "--type", "word", "--program", "-", allow_fallback=True),
    shortcut("visible-text", "Insert selected hash.", (mod.leader + "p") > "h", "kitten", "hints", "--type", "hash", "--program", "-", allow_fallback=True),
    shortcut("visible-text", "Open selected file at line number.", (mod.leader + "p") > "n", "kitten", "hints", "--type", "linenum", allow_fallback=True),
    shortcut("visible-text", "Open selected hyperlink.", (mod.leader + "p") > "y", "kitten", "hints", "--type", "hyperlink", allow_fallback=True),
    shortcut("miscellaneous", "Show kitty documentation.", mod.leader + "f1", "show_kitty_doc", "overview"),
    shortcut("miscellaneous", "Open command palette.", mod.leader + "f3", "command_palette"),
    shortcut("miscellaneous", "Toggle fullscreen.", mod.leader + "f11", "toggle_fullscreen"),
    shortcut("miscellaneous", "Toggle fullscreen.", mod.ctrl + mod.cmd + "f", "toggle_fullscreen", allow_fallback=True),
    shortcut("miscellaneous", "Toggle maximized window state.", mod.leader + "f10", "toggle_maximized"),
    shortcut("miscellaneous", "Toggle macOS secure keyboard entry.", mod.opt + mod.cmd + "s", "toggle_macos_secure_keyboard_entry", allow_fallback=True),
    shortcut("miscellaneous", "Cycle through macOS OS windows.", mod.cmd + "`", "macos_cycle_through_os_windows"),
    shortcut("miscellaneous", "Cycle through macOS OS windows backwards.", mod.cmd + mod.shift + "`", "macos_cycle_through_os_windows_backwards"),
    shortcut("miscellaneous", "Open Unicode input kitten.", mod.leader + "u", "kitten", "unicode_input", allow_fallback=True),
    shortcut("miscellaneous", "Open Unicode input kitten.", mod.ctrl + mod.cmd + "space", "kitten", "unicode_input"),
    shortcut("miscellaneous", "Edit kitty config file.", mod.leader + "f2", "edit_config_file"),
    shortcut("miscellaneous", "Edit kitty config file.", mod.cmd + ",", "edit_config_file"),
    shortcut("miscellaneous", "Open kitty command shell in window.", mod.leader + "escape", "kitty_shell", "window"),
    shortcut("miscellaneous", "Increase background opacity.", (mod.leader + "a") > "m", "set_background_opacity", "+0.1", allow_fallback=True),
    shortcut("miscellaneous", "Decrease background opacity.", (mod.leader + "a") > "l", "set_background_opacity", "-0.1", allow_fallback=True),
    shortcut("miscellaneous", "Make background fully opaque.", (mod.leader + "a") > 1, "set_background_opacity", "1", allow_fallback=True),
    shortcut("miscellaneous", "Reset background opacity.", (mod.leader + "a") > "d", "set_background_opacity", "default", allow_fallback=True),
    shortcut("miscellaneous", "Reset terminal.", mod.leader + "delete", "clear_terminal", "reset", "active"),
    shortcut("miscellaneous", "Reset terminal.", mod.opt + mod.cmd + "r", "clear_terminal", "reset", "active"),
    shortcut("miscellaneous", "Clear to prompt start.", mod.cmd + "k", "clear_terminal", "to_cursor", "active"),
    shortcut("miscellaneous", "Clear scrollback.", mod.option + mod.cmd + "k", "clear_terminal", "scrollback", "active"),
    shortcut("miscellaneous", "Clear last command.", mod.cmd + "l", "clear_terminal", "last_command", "active"),
    shortcut("miscellaneous", "Clear screen and keep scrollback.", mod.cmd + mod.ctrl + "l", "clear_terminal", "to_cursor_scroll", "active"),
    shortcut("miscellaneous", "Reload kitty.conf.", mod.leader + "f5", "load_config_file"),
    shortcut("miscellaneous", "Reload kitty.conf.", mod.ctrl + mod.cmd + ",", "load_config_file"),
    shortcut("miscellaneous", "Show effective kitty configuration.", mod.leader + "f6", "debug_config"),
    shortcut("miscellaneous", "Show effective kitty configuration.", mod.opt + mod.cmd + ",", "debug_config"),
    shortcut("miscellaneous", "Open kitty website.", mod.shift + mod.cmd + "/", "open_url", "https://sw.kovidgoyal.net/kitty/"),
    shortcut("miscellaneous", "Hide macOS kitty application.", mod.cmd + "h", "hide_macos_app"),
    shortcut("miscellaneous", "Hide other macOS applications.", mod.opt + mod.cmd + "h", "hide_macos_other_apps"),
    shortcut("miscellaneous", "Minimize macOS window.", mod.cmd + "m", "minimize_macos_window"),
    shortcut("miscellaneous", "Quit kitty.", mod.cmd + "q", "quit"),
)
    builder.comment(KEYBOARD_SHORTCUTS_DOC)
    builder.comment("Kitty default shortcuts rendered through Key, KeyModifier, Keymap, and KeySequence.")
    builder.blank()

    current_section = ""
    for shortcut_def in DEFAULT_SHORTCUTS:
        if shortcut_def.section != current_section:
            if current_section:
                builder.blank()
            builder.comment(shortcut_def.section.replace("-", " "))
            builder.blank()
            current_section = shortcut_def.section

        builder.comment(shortcut_def.docs_link)
        builder.comment(shortcut_def.description)
        builder.map(shortcut_def.keymap, shortcut_def.action, *shortcut_def.args, map_options=shortcut_def.map_options)
        builder.blank()
