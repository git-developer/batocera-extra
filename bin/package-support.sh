log() {
  echo >&2 "${@}"
}

apply_cache() {
  cache="${1}" key="${2}" value="${3}"

  if [ "${value}" ]; then
    entry="$(printf '%s\t%s' "${key}" "${value}")"
    if ! grep -q -F "${entry}" "${cache}" 2>/dev/null; then
      if [ -r "${cache}" ] && grep -q -F "${key}" "${cache}"; then
        other_entries="$(grep -v -F "${key}" "${cache}")"
        echo "${other_entries}" >"${cache}"
      fi
      log "Adding cache entry: ${entry}"
      echo "${entry}" >>"${cache}"
    fi
    echo "${value}"
  elif [ -r "${cache}" ]; then
    log "${key} not found, reading from cache:"
    grep -F "${key}" "${cache}" | cut -f 2 | tee -a /dev/stderr
  fi
}

provide_package() {
  source="${1}" target="${2}"

  package="${source}"
  if [ ! -r "${source}" ]; then
    filename="$(wget --quiet --spider --server-response "${source}" 2>&1 | sed -nE 's/\s*content-disposition.+filename=(.+)/\1/pi')"
    filename="$(apply_cache "${target}/.url-cache" "${source}" "${filename}")"
    filename="${filename:-${source##*/}}"
    if [ "${filename}" ]; then
      package="${target}/${filename}"
      if [ -s "${package}" ]; then
        log "Using up-to-date local file ${package}"
      else
        mkdir -p "${target}"
        wget --quiet "--output-document=${package}" "${source}" || {
          rc="$?"
          log "Error downloading ${source}"
          return "$rc"
        }
      fi
    fi
  fi
  echo "${package}"
}

find_latest_github_release() {
  repo="${1}"
  prefix="${2-}"
  suffix="${3-}"

  wget -q -O - "https://api.github.com/repos/${repo}/releases/latest" \
  | jq -r --arg prefix "${prefix}" --arg suffix "${suffix}" \
    '.assets[] | select((.name|startswith($prefix)) and (.name|endswith($suffix))).browser_download_url'
}

prepare_pip() {
  if ! command -V pip >/dev/null 2>&1; then
    python -m ensurepip --upgrade
    python -m pip install --root-user-action=ignore --upgrade pip
  fi
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
