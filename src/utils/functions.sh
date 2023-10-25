#!/usr/bin/env bash

set -eo pipefail
[[ $CLI_TRACE ]] && set -x

has_tty() {
  declare desc="return 0 if we have a tty"
  if [[ "$RCLI_DISABLE_TTY" == "true" ]]; then
    return 1
  fi

  if [[ "$(LC_ALL=C /usr/bin/tty || true)" == "not a tty" ]]; then
    return 1
  else
    return 0
  fi
}

cli_apps() {
  declare desc="prints list of all local apps"
  declare FILTER="$1"
  local INSTALLED_APPS="$(plugn trigger app-list "$FILTER")"
  if [[ -z "$INSTALLED_APPS" ]]; then
    cli_log_fail "You haven't deployed any applications yet"
  fi
  echo "$INSTALLED_APPS"
}

check_for_updates() {
    # Location of the version file on GitHub
    VERSION_URL="https://raw.githubusercontent.com/sec0nd_hand/RCLI/main/VERSION.txt"

    # Fetch the latest version from GitHub
    LATEST_VERSION=$(curl -s $VERSION_URL)

    # Fetch the local version
    if [[ -f "$LIBRARY_ROOT/VERSION" ]]; then
      LOCAL_VERSION=$(cat "${LIBRARY_ROOT}/VERSION")
    else
      cli_log_fail "Unable to determine icli's version"
    fi
    # Check if an update is available
    if [[ "$LATEST_VERSION" != "$LOCAL_VERSION" ]]; then
        echo "A new version of RCLI is available!"
        # Add the logic to update RCLI if needed
    else
        echo "RCLI is up to date!"
    fi
}

should_update() {
  today=$(date +%Y-%m-%d)
  last_checked=""

  # Check if the file exists and read the date
  [[ -f "$LIBRARY_ROOT/LAST_CHECKED" ]] && last_checked=$(cat $LIBRARY_ROOT/LAST_CHECKED)

  # If it's been a week or if it's the first check
  if [[ "$today" > "$last_checked" || -z "$last_checked" ]]; then
      check_for_updates
      echo $today > $LIBRARY_ROOT/LAST_CHECKED
      echo $today
    else
      echo 'no'
  fi
}

cli_version() {
  if [[ -f "$LIBRARY_ROOT/VERSION" ]]; then
    CLI_VERSION=$(cat "${LIBRARY_ROOT}/VERSION")
  else
    cli_log_fail "Unable to determine icli's version"
  fi
  echo "icli version ${CLI_VERSION}"
}

cli_help_args() {
  declare desc="help args indentation"
  echo "   $*"
}

cli_log_warn() {
  declare desc="log warn formatter"
  echo " !     $*"
}

cli_log_fail() {
  declare desc="log fail formatter"
  echo "!-----> $*"
}

cli_log_quiet() {
  declare desc="log quiet formatter"
  if [[ -z "$QUIET_OUTPUT" ]]; then
    echo "$*"
  fi
}


fn-is-compose-installed() {
  declare desc="check if the compose docker plugin is installed"
  local COMPOSE_INSTALLED
  COMPOSE_INSTALLED="$(docker info -f '{{range .ClientInfo.Plugins}}{{if eq .Name "compose"}}true{{end}}{{end}}')"

  if [[ "$COMPOSE_INSTALLED" == "true" ]]; then
    return 0
  fi

  return 1
}

is_number() {
  declare desc="returns 0 if input is a number"
  local NUMBER=$1
  local NUM_RE='^[0-9]+$'
  if [[ $NUMBER =~ $NUM_RE ]]; then
    return 0
  else
    return 1
  fi
}

is_abs_path() {
  declare desc="returns 0 if input path is absolute"
  local TEST_PATH=$1
  if [[ "$TEST_PATH" == /* ]]; then
    return 0
  else
    return 1
  fi
}

get_json_value() {
  declare desc="return value of provided json key from a json stream on stdin"
  # JSON_NODE should be expresses as either a top-level object that has no children
  # or in the format of .json.node.path
  local JSON_NODE="$1"

  cat | jq -r "${JSON_NODE} | select (.!=null)" 2>/dev/null
}

strip_inline_comments() {
  declare desc="removes bash-style comment from input line"
  local line="$1"
  local stripped_line="${line%[[:space:]]#*}"

  echo "$stripped_line"
}

is_val_in_list() {
  declare desc="return true if value ($1) is in list ($2) separated by delimiter ($3); delimiter defaults to comma"
  local value="$1" list="$2" delimiter="${3:-,}"
  local IFS="$delimiter" val_in_list=false

  for val in $list; do
    if [[ "$val" == "$value" ]]; then
      val_in_list=true
    fi
  done

  echo "$val_in_list"
}

fn-in-array() {
  declare desc="return true if value ($1) is in list (all other arguments)"

  local e
  for e in "${@:2}"; do
    [[ "$e" == "$1" ]] && return 0
  done
  return 1
}

remove_val_from_list() {
  declare desc="remove value ($1) from list ($2) separated by delimiter ($3) (delimiter defaults to comma) and return list"
  local value="$1" list="$2" delimiter="${3:-,}"
  list="${list//$value/}"
  list="${list//$delimiter$delimiter/$delimiter}"
  list="${list/#$delimiter/}"
  list="${list/%$delimiter/}"
  echo "$list"
}

add_val_to_list() {
  declare desc="add value ($1) to list ($2) separated by delimiter ($3) (delimiter defaults to comma) and return list"
  local value="$1" list="$2" delimiter="${3:-,}"
  list+="${delimiter}$value"
  echo "$list"
}

merge_dedupe_list() {
  declare desc="combine lists ($1) separated by delimiter ($2) (delimiter defaults to comma), dedupe and return list"
  local input_lists="$1" delimiter="${2:-,}"

  local merged_list="$(tr "$delimiter" $'\n' <<<"$input_lists" | sort | uniq | xargs)"
  echo "$merged_list"
}

suppress_output() {
  declare desc="suppress all output from a given command unless there is an error"
  local TMP_COMMAND_OUTPUT
  TMP_COMMAND_OUTPUT=$(mktemp "/tmp/icli-${RCLI_PID}-${FUNCNAME[0]}.XXXXXX")
  trap "rm -rf '$TMP_COMMAND_OUTPUT' >/dev/null" RETURN

  "$@" >"$TMP_COMMAND_OUTPUT" 2>&1 || {
    local exit_code="$?"
    cat "$TMP_COMMAND_OUTPUT"
    return "$exit_code"
  }
  return 0
}

