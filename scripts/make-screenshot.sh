#!/bin/bash

function screenshot_light {
    convert \
        -size 2880x1800 \
        gradient:orange-darkorange \
        "$1" \
        -gravity Center \
        -geometry +0+36 \
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
        -geometry +0+36 \
        -composite "$2"
}

screenshot_light "graphics/screenshots/screenshot-default@2x.png" "graphics/screenshots/screenshot-appstore@2x.png"
screenshot_light "graphics/screenshots/screenshot-where@2x.png" "graphics/screenshots/screenshot-appstore-where@2x.png"
screenshot_dark "graphics/screenshots/screenshot-default-dark@2x.png" "graphics/screenshots/screenshot-appstore-dark@2x.png"
screenshot_dark "graphics/screenshots/screenshot-where-dark@2x.png" "graphics/screenshots/screenshot-appstore-where-dark@2x.png"
