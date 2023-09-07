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
           /userdata/extra/patches/relocate-root-dotfiles-to-home
           /userdata/extra/patches/patch-joycond-for-flatpak
           /userdata/extra/patches/patch-cemu-generator-for-cemuhook
           /userdata/extra/evdevhook2/install-and-start
           /userdata/extra/linuxmotehook2/install-and-start
           /userdata/extra/joycond-cemuhook/install
           /userdata/extra/dsdrv-cemuhook/install
           /userdata/extra/sdgyrodsu/install
           /userdata/extra/remote-touchpad/start
           ;;
  stop)    /userdata/extra/remote-touchpad/stop
           /userdata/extra/linuxmotehook2/stop
           /userdata/extra/evdevhook2/stop
           ;;
  restart) ;;
  reload)  ;;
  *)
esac
