#!/bin/sh
set -u
echo "$(date -Iseconds)" "${0}" "${@}" >&2
export PATH="${PATH}:$(dirname "$(readlink -f "${0}")")"

# HOME is '/' when this script is run from the init process;
# some of the scripts expect the batocera default '/userdata/system' instead
if [ "${HOME}" = '/' ]; then
  export HOME='/userdata/system'
fi

case "${1-}" in
  start)
           /userdata/extra/bin/install-from-arch patch
           /userdata/extra/patches/patch-joycond-for-flatpak
           /userdata/extra/patches/relocate-root-dotfiles-to-home
           /userdata/extra/patches/patch-cemu-generator-for-cemuhook
           /userdata/extra/patches/mark-dbus-python-as-installed
           /userdata/extra/joycond-cemuhook/install-and-start
           /userdata/extra/ds4drv-cemuhook/install-and-start
           /userdata/extra/linuxmotehook2/install-and-start
           /userdata/extra/remote-touchpad/start
           ;;
  stop)    /userdata/extra/remote-touchpad/stop
           /userdata/extra/linuxmotehook2/stop
           /userdata/extra/ds4drv-cemuhook/stop
           /userdata/extra/joycond-cemuhook/stop
           ;;
  restart) ;;
  reload)  ;;
  *)
esac
