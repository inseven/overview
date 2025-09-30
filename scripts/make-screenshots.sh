#!/bin/bash

ROOT_DIRECTORY="$( cd "$( dirname "$( dirname "${BASH_SOURCE[0]}" )" )" &> /dev/null && pwd )"

function screenshot_light {
    convert \
        -size 2880x1800 \
        gradient:orange-darkorange \
        "$1" \
        -gravity Center \
        -geometry +0+0 \
        -composite "$2"
}

function screenshot_dark {
    convert \
        -size 2880x1800 \
        gradient:orange-darkorange \
        -modulate 80,100,100 \
        -colorize -40% \
        "$1" \
        -gravity Center \
        -geometry +0+0 \
        -composite "$2"
}

screenshot_light "$ROOT_DIRECTORY/docs/images/screenshot-default@2x.png" "$ROOT_DIRECTORY/graphics/screenshots/screenshot-appstore@2x.png"
screenshot_light "$ROOT_DIRECTORY/docs/images/screenshot-where@2x.png" "$ROOT_DIRECTORY/graphics/screenshots/screenshot-appstore-where@2x.png"
screenshot_dark "$ROOT_DIRECTORY/docs/images/screenshot-default-dark@2x.png" "$ROOT_DIRECTORY/graphics/screenshots/screenshot-appstore-dark@2x.png"
screenshot_dark "$ROOT_DIRECTORY/docs/images/screenshot-where-dark@2x.png" "$ROOT_DIRECTORY/graphics/screenshots/screenshot-appstore-where-dark@2x.png"
