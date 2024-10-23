function prepare-default-paths () {
  paths=()
  for path in `cat /etc/paths`; do
    paths+=$path
  done
  echo ${(j/:/)paths}
}

function change-platform () {
  local current_platform="$(uname -m)"
  local next_platform="$1"

  if [ "$current_platform" = "$next_platform" ] ; then
    return
  fi

  local critical_vars=("PATH" "PLATFORM_HIST" "PATH_HIST" "HOME" "USER" "SHELL" "TERM")
  for var in $(env | cut -d= -f1); do
    if [[ ! " ${critical_vars[@]} " =~ " $var " ]]; then
      unset $var
    fi
  done

  case "${next_platform}" in
    arm64*)
      arch -arm64  env PATH="$(prepare-default-paths)" PLATFORM_HIST="$PLATFORM_HIST" PATH_HIST="$PATH_HIST" zsh ;;
    x86_64*)
      arch -x86_64 env PATH="$(prepare-default-paths)" PLATFORM_HIST="$PLATFORM_HIST" PATH_HIST="$PATH_HIST" zsh ;;
  esac
}

# user facing interface
function set-platform () {
  echo "$1" > .apple-silicon-platform
}

# user facing interface
function use-platform () {
  push-front $1
}

function push-front () {
  local path="$(PWD)"

  if [ -z "$PATH_HIST" ]; then
    PATH_HIST="$path"
    PLATFORM_HIST="$1"
  else
    PATH_HIST="$path,$PATH_HIST"
    PLATFORM_HIST="$1,$PLATFORM_HIST"
  fi
}

function pop-front () {
  if [ -z "$PATH_HIST" ]; then
    return
  fi

  PATH_HIST=$(echo "$PATH_HIST" | awk '{
    sub(/^[^,]*,?/, "")
    print
  }')
  PLATFORM_HIST=$(echo "$PLATFORM_HIST" | awk '{
    sub(/^[^,]*,?/, "")
    print
  }')
}

function get-front-platform() {
  echo "$PLATFORM_HIST" | cut -d , -f 1
}

function get-front-path() {
  echo "$PATH_HIST" | cut -d , -f 1
}

function switch-platform () {
  local platform_file=.apple-silicon-platform

  while [[ $(pwd) != "$(get-front-path)"* ]] ; do
    if [ -z "$(get-front-path)" ] ; then
      break
    fi
    pop-front
  done

  if test -f $platform_file ; then
    if [[ "$(PWD)" != "$(get-front-path)" ]] ; then
      push-front "$(cat $platform_file)"
    fi
  fi

  # default to "arm64"
  local default_platform="${DEFAULT_APPLE_SILICON_PLATFORM:-arm64}"
  case "$(get-front-platform)" in
    arm64*)
      change-platform "arm64"  ;;
    x86_64*)
      change-platform "x86_64" ;;
    *)
      change-platform $default_platform  ;;
  esac
}

# note(himkt); overwriting exit command since builtin exit does not work with zsh-platform-switcher
# https://github.com/himkt/zsh-platform-switcher/issues/1
function exit () {
  if [ -f ".apple-silicon-platform" ]; then
    echo "$(tput setaf 1)Warning$(tput sgr0): exit doesn't work when .apple-silicon-platform exists on the current directory."
    return
  fi
  if [ -z "$(get-front-platform)" ]; then
    echo "$(tput setaf 1)Warning$(tput sgr0): exit does not work when get-front-platform is empty."
    echo "Please close a window directly."
    return
  fi
  pop-front
}

typeset -a precmd_functions
precmd_functions+=(switch-platform)
