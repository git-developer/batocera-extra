log() {
  echo >&2 "${@}"
}

prepare_pip() {
  if ! command -V pip >/dev/null 2>&1; then
    python -m ensurepip --upgrade
    python -m pip install --upgrade pip
  fi
}

provide_package() {
  source="${1}" target="${2}"

  package="${source}"
  if [ ! -r "${source}" ]; then
    filename="$(wget --quiet --spider --server-response "${source}" 2>&1 | sed -nE 's/\s*content-disposition.+filename=(.+)/\1/pi')"
    filename="${filename:-${source##*/}}"
    if [ "${filename}" ]; then
      package="${target}/${filename}"
      if [ -s "${package}" ]; then
        log "Using up-to-date local file ${package}"
      else
        mkdir -p "${target}"
        wget --quiet "--output-document=${package}" "${source}"
      fi
    fi
  fi
  echo "${package}"
}

find_package_source() {
  name="${1}"
  source="${2}"
  target="${3:-${XDG_CACHE_HOME:-/userdata/system/.cache}/${name}}"

  prepare_pip >&2

  # simpler 'grep -q ...' would cause a python message on SIGPIPE
  if pip list | grep "${name}" | grep -q .; then
    log "Python package '${name}' is already installed."
  else
    provide_package "${source}" "${target}"
  fi
}
