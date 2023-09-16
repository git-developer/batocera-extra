set -eu
. "$(readlink -f "$(dirname "$0")")/.env"

log() {
  echo >&2 "${@}"
}

list_profiles() {
  find "${base_dir}/profiles" -name '*.ini' -exec basename '{}' .ini \;
}

path_of() {
  path="${base_dir}/profiles/${1}.ini"
  if [ -e "${path}" ]; then
    echo "${path}"
  else
    log "Error: No profile in '${path}'."
    return 1
  fi
}
