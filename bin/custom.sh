#!/bin/sh
set -eu
echo "$(date -Iseconds)" "${0}" "${@}" >&2

case "${1-}" in
  start)
           /userdata/extra/patches/patch-citra-generator-for-language
           /userdata/extra/patches/patch-citra-generator-for-cemuhook
           /userdata/extra/patches/patch-cemu-generator-for-squashfs
           /userdata/extra/patches/patch-cemu-generator-for-cemuhook
           /userdata/extra/patches/patch-batocera-info-for-pro-controller
           /userdata/extra/patches/mark-dbus-python-as-installed
           /userdata/extra/joycond-cemuhook/install-and-start
           /userdata/extra/ds4drv-cemuhook/install-and-start
           /userdata/extra/remote-touchpad/start
           ;;
  stop)    /userdata/extra/remote-touchpad/stop
           /userdata/extra/ds4drv-cemuhook/stop
           /userdata/extra/joycond-cemuhook/stop
           ;;
  restart) ;;
  reload)  ;;
  *)
esac
