#!/usr/bin/env bash
# dirs first in Nautilus (GTK4) + legacy GTK3 file choosers
set -euo pipefail

gsettings set org.gtk.gtk4.Settings.FileChooser sort-directories-first true
gsettings set org.gtk.Settings.FileChooser sort-directories-first true
