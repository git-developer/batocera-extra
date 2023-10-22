#!/bin/sh
set -u

base_dir="$(readlink -f "$(dirname "$0")")"
echo "$(date -Iseconds)" "${0}" "${@}" >&2

apply_patches() {
  patches_dir="$(readlink -f "$(dirname "${base_dir}")/patches")"

  "${patches_dir}/relocate-root-dotfiles-to-home"
  "${patches_dir}/patch-joycond-for-flatpak"
  "${patches_dir}/patch-cemu-generator-for-cemuhook"
}

enabled_services() {
  action="${1}"

  batocera-services list user | sed -nE 's/^([^;]+);\*$/\1/p' | while read service; do
    batocera-services "${action}" "${service}"
  done
}

main() {

  # HOME is '/' when this script is run from the init process;
  # some of the scripts expect the batocera default '/userdata/system' instead
  if [ "${HOME}" = '/' ]; then
    export HOME='/userdata/system'
  fi

  case "${1-}" in
    start)
      apply_patches
      "${base_dir}/extra-services" install
      enabled_services start
      ;;
    stop)
      enabled_services stop
      ;;
    restart) ;;
    reload)  ;;
    *)
  esac
}

main "${@}"
