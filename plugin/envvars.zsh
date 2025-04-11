#!/usr/bin/env zsh

#
# Copyright (c) 2024, 2025 Džiugas Eiva GPL-3.0-only
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public Licence as published by
# the Free Software Foundation version 3 of the Licence.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public Licence for more details.
#
# You should have received a copy of the GNU General Public Licence
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

# use viddy (if available) instead of watch for https://github.com/Thearas/zsh-watch plugin
(( ${+commands[viddy]} )) && export ZSH_WATCH=viddy ZSH_WATCH_FLAGS="-dtws --disable_auto_save"
