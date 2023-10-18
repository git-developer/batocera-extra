#!/bin/sh
set -u
echo "$(date -Iseconds)" "${0}" "${@}" >&2
export PATH="${PATH}:$(readlink -f "$(dirname "$0")")"

# HOME is '/' when this script is run from the init process;
# some of the scripts expect the batocera default '/userdata/system' instead
if [ "${HOME}" = '/' ]; then
  export HOME='/userdata/system'
fi

case "${1-}" in
  start)
           /userdata/extra/bin/register-services
           batocera-services list user | sed -nE 's/^([^;]+);\*$/\1/p' | while read service; do
             batocera-services start "${service}"
           done
           ;;
  stop)
           batocera-services list user | sed -nE 's/^([^;]+);\*$/\1/p' | while read service; do
             batocera-services stop "${service}"
           done
           ;;
  restart) ;;
  reload)  ;;
  *)
esac
