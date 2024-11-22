#!/bin/bash

# Takes a screenshot and opens it in Shutter

set -x

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

main() {
    mkdir -p "$SCREENSHOT_DIR"
    cd "$SCREENSHOT_DIR"

    SCREENSHOT_NAME="$(date +%Y-%m-%d_%H-%M-%S-%N.png)"

    if [[ -z "$1" ]]; then
        echo "Fatal error: Missing selection mode argument" >&2
        echo >&2
        usage >&2
        exit 1
    fi

    if [[ "$1" == "-s" ]]; then
        grim -g "$(slurp)" "$SCREENSHOT_NAME"
    fi

    if [[ "$1" == "-w" ]]; then
        SELECTION="$(
            swaymsg -t get_tree \
                | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' \
                | slurp
        )"

        grim -g "$SELECTION" "$SCREENSHOT_NAME"
    fi

    # Launch Shutter first using gtk-launch, so there's no risk of Shutter
    # being attached to the current terminal
    gtk-launch shutter

    shutter "$SCREENSHOT_DIR/$SCREENSHOT_NAME"
}

usage() {
    echo "USAGE: screenshot {-s|-w}"
    echo
    echo "Options:"
    echo "  -s  Grab selection (rectangle)"
    echo "  -w  Grab window"
}

main "$@"
