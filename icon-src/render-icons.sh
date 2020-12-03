#!/bin/bash
#
# This file is part of harbour-wunderfitz.
# Copyright (C) 2019-2020  Mirian Margiani
#
# harbour-wunderfitz is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# harbour-wunderfitz is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with harbour-wunderfitz.  If not, see <http://www.gnu.org/licenses/>.
#

postfix=""  # could be e.g. '-beta'

# ----------------

generated=()
target=
prepare() { # 1: target directory
    target="$1"
    mkdir -p "$1"
}

render() { # 1: source base name (without .svg), 2: target base name (without .png), 3: width, 4: height
    local in="$1.svg"
    local out="$target/$2.png"

    if [[ ! -f "$in" ]]; then
        echo "$in skipped"
        return
    fi

    if [[ ! "$in" -nt "$out" ]]; then
        echo "nothing to do for $in (-> $out)"
        return
    fi

    # replace '-o' by '-z -e' for inkscape < 1.0
    inkscape -o "$out" -w "$3" -h "$4" "$in"
    generated+=("$out")
}

echo "rendering app icon..."
appicons=(harbour-wunderfitz)
for i in 86 108 128 172 256; do
    prepare "../icons/${i}x$i"
    for a in "${appicons[@]}"; do
        # shared files need the postfix
        render "$a$postfix" "$a$postfix" "$i" "$i"
    done
done

echo "rendering images..."
images=(harbour-wunderfitz@860x860 background@460x736)
prepare "../images"
for i in "${images[@]}"; do
    file="${i%@*}"; w="${i#*@}"; w="${w%x*}"; h="${i#*@*x}"
    # images are not shared, output files don't need the postfix
    render "$file$postfix" "${file#harbour-}" "$w" "$h"
done

echo "shrinking files..."
for i in "${generated[@]}"; do
    pngcrush "$i" "$i#"
    mv "$i#" "$i"
done
