#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# or via wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# or via fetch:
#   sh -c "$(fetch -o - https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
#   sh install.sh
#
# You can tweak the install behavior by setting variables when running the script. For
# example, to change the path to the Oh My Zsh repository:
#   ZSH=~/.zsh sh install.sh
#
# Respects the following environment variables:
#   ZSH     - path to the Oh My Zsh repository folder (default: $HOME/.oh-my-zsh)
#   REPO    - name of the GitHub repo to install from (default: ohmyzsh/ohmyzsh)
#   REMOTE  - full remote URL of the git repo to install (default: GitHub via HTTPS)
#   BRANCH  - branch to check out immediately after install (default: master)
#
# Other options:
#   CHSH       - 'no' means the installer will not change the default shell (default: yes)
#   RUNZSH     - 'no' means the installer will not run zsh after the install (default: yes)
#   KEEP_ZSHRC - 'yes' means the installer will not replace an existing .zshrc (default: no)
#
# You can also pass some arguments to the install script to set some these options:
#   --skip-chsh: has the same behavior as setting CHSH to 'no'
#   --unattended: sets both CHSH and RUNZSH to 'no'
#   --keep-zshrc: sets KEEP_ZSHRC to 'yes'
# For example:
#   sh install.sh --unattended
# or:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
#
set -e

# Track if $ZSH was provided
custom_zsh=${ZSH:+yes}

# Default settings
ZSH=${ZSH:-~/.oh-my-zsh}
REPO=${REPO:-ohmyzsh/ohmyzsh}
REMOTE=${REMOTE:-git@github.com:${REPO}.git}
BRANCH=${BRANCH:-master}

# Other options
CHSH=${CHSH:-yes}
RUNZSH=${RUNZSH:-yes}
KEEP_ZSHRC=${KEEP_ZSHRC:-no}


command_exists() {
  command -v "$@" >/dev/null 2>&1
}

# The [ -t 1 ] check only works when the function is not called from
# a subshell (like in `$(...)` or `(...)`, so this hack redefines the
# function at the top level to always return false when stdout is not
# a tty.
if [ -t 1 ]; then
  is_tty() {
    true
  }
else
  is_tty() {
    false
  }
fi

# This function uses the logic from supports-hyperlinks[1][2], which is
# made by Kat Marchán (@zkat) and licensed under the Apache License 2.0.
# [1] https://github.com/zkat/supports-hyperlinks
# [2] https://crates.io/crates/supports-hyperlinks
#
# Copyright (c) 2021 Kat Marchán
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
supports_hyperlinks() {
  # $FORCE_HYPERLINK must be set and be non-zero (this acts as a logic bypass)
  if [ -n "$FORCE_HYPERLINK" ]; then
    [ "$FORCE_HYPERLINK" != 0 ]
    return $?
  fi

  # If stdout is not a tty, it doesn't support hyperlinks
  is_tty || return 1

  # DomTerm terminal emulator (domterm.org)
  if [ -n "$DOMTERM" ]; then
    return 0
  fi

  # VTE-based terminals above v0.50 (Gnome Terminal, Guake, ROXTerm, etc)
  if [ -n "$VTE_VERSION" ]; then
    [ $VTE_VERSION -ge 5000 ]
    return $?
  fi

  # If $TERM_PROGRAM is set, these terminals support hyperlinks
  case "$TERM_PROGRAM" in
  Hyper|iTerm.app|terminology|WezTerm) return 0 ;;
  esac

  # kitty supports hyperlinks
  if [ "$TERM" = xterm-kitty ]; then
    return 0
  fi

  # Windows Terminal or Konsole also support hyperlinks
  if [ -n "$WT_SESSION" ] || [ -n "$KONSOLE_VERSION" ]; then
    return 0
  fi

  return 1
}

fmt_link() {
  # $1: text, $2: url, $3: fallback mode
  if supports_hyperlinks; then
    printf '\033]8;;%s\a%s\033]8;;\a\n' "$2" "$1"
    return
  fi

  case "$3" in
  --text) printf '%s\n' "$1" ;;
  --url|*) fmt_underline "$2" ;;
  esac
}

fmt_underline() {
  is_tty && printf '\033[4m%s\033[24m\n' "$*" || printf '%s\n' "$*"
}

# shellcheck disable=SC2016 # backtick in single-quote
fmt_code() {
  is_tty && printf '`\033[2m%s\033[22m`\n' "$*" || printf '`%s`\n' "$*"
}

fmt_error() {
  printf '%sError: %s%s\n' "$BOLD$RED" "$*" "$RESET" >&2
}

setup_color() {
  # Only use colors if connected to a terminal
  if is_tty; then
    RAINBOW="
      $(printf '\033[38;5;196m')
      $(printf '\033[38;5;202m')
      $(printf '\033[38;5;226m')
      $(printf '\033[38;5;082m')
      $(printf '\033[38;5;021m')
      $(printf '\033[38;5;093m')
      $(printf '\033[38;5;163m')
    "
    RED=$(printf '\033[31m')
    GREEN=$(printf '\033[32m')
    YELLOW=$(printf '\033[33m')
    BLUE=$(printf '\033[34m')
    BOLD=$(printf '\033[1m')
    RESET=$(printf '\033[m')
  else
    RAINBOW=""
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    RESET=""
  fi
}

setup_ohmyzsh() {
  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  echo "${BLUE}Cloning Oh My Zsh...${RESET}"

  command_exists git || {
    fmt_error "git is not installed"
    exit 1
  }

  ostype=$(uname)
  if [ -z "${ostype%CYGWIN*}" ] && git --version | grep -q msysgit; then
    fmt_error "Windows/MSYS Git is not supported on Cygwin"
    fmt_error "Make sure the Cygwin git package is installed and is first on the \$PATH"
    exit 1
  fi

  git clone -c core.eol=lf -c core.autocrlf=false \
    -c fsck.zeroPaddedFilemode=ignore \
    -c fetch.fsck.zeroPaddedFilemode=ignore \
    -c receive.fsck.zeroPaddedFilemode=ignore \
    -c oh-my-zsh.remote=origin \
    -c oh-my-zsh.branch="$BRANCH" \
    --depth=1 --branch "$BRANCH" "$REMOTE" "$ZSH" || {
    fmt_error "git clone of oh-my-zsh repo failed"
    exit 1
  }

  echo
}

setup_zshrc() {
  # Keep most recent old .zshrc at .zshrc.pre-oh-my-zsh, and older ones
  # with datestamp of installation that moved them aside, so we never actually
  # destroy a user's original zshrc
  echo "${BLUE}Looking for an existing zsh config...${RESET}"

  # Must use this exact name so uninstall.sh can find it
  OLD_ZSHRC=~/.zshrc.pre-oh-my-zsh
  if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
    # Skip this if the user doesn't want to replace an existing .zshrc
    if [ "$KEEP_ZSHRC" = yes ]; then
      echo "${YELLOW}Found ~/.zshrc.${RESET} ${GREEN}Keeping...${RESET}"
      return
    fi
    if [ -e "$OLD_ZSHRC" ]; then
      OLD_OLD_ZSHRC="${OLD_ZSHRC}-$(date +%Y-%m-%d_%H-%M-%S)"
      if [ -e "$OLD_OLD_ZSHRC" ]; then
        fmt_error "$OLD_OLD_ZSHRC exists. Can't back up ${OLD_ZSHRC}"
        fmt_error "re-run the installer again in a couple of seconds"
        exit 1
      fi
      mv "$OLD_ZSHRC" "${OLD_OLD_ZSHRC}"

      echo "${YELLOW}Found old ~/.zshrc.pre-oh-my-zsh." \
        "${GREEN}Backing up to ${OLD_OLD_ZSHRC}${RESET}"
    fi
    echo "${YELLOW}Found ~/.zshrc.${RESET} ${GREEN}Backing up to ${OLD_ZSHRC}${RESET}"
    mv ~/.zshrc "$OLD_ZSHRC"
  fi

  echo "${GREEN}Using the Oh My Zsh template file and adding it to ~/.zshrc.${RESET}"

  sed "/^export ZSH=/ c\\
export ZSH=\"$ZSH\"
" "$ZSH/templates/zshrc.zsh-template" > ~/.zshrc-omztemp
  mv -f ~/.zshrc-omztemp ~/.zshrc

  echo
}

setup_shell() {
  # Skip setup if the user wants or stdin is closed (not running interactively).
  if [ "$CHSH" = no ]; then
    return
  fi

  # If this user's login shell is already "zsh", do not attempt to switch.
  if [ "$(basename -- "$SHELL")" = "zsh" ]; then
    return
  fi

  # If this platform doesn't provide a "chsh" command, bail out.
  if ! command_exists chsh; then
    cat <<EOF
I can't change your shell automatically because this system does not have chsh.
${BLUE}Please manually change your default shell to zsh${RESET}
EOF
    return
  fi

  echo "${BLUE}Time to change your default shell to zsh:${RESET}"

  # Prompt for user choice on changing the default login shell
  printf '%sDo you want to change your default shell to zsh? [Y/n]%s ' \
    "$YELLOW" "$RESET"
  read -r opt
  case $opt in
    y*|Y*|"") echo "Changing the shell..." ;;
    n*|N*) echo "Shell change skipped."; return ;;
    *) echo "Invalid choice. Shell change skipped."; return ;;
  esac

  # Check if we're running on Termux
  case "$PREFIX" in
    *com.termux*) termux=true; zsh=zsh ;;
    *) termux=false ;;
  esac

  if [ "$termux" != true ]; then
    # Test for the right location of the "shells" file
    if [ -f /etc/shells ]; then
      shells_file=/etc/shells
    elif [ -f /usr/share/defaults/etc/shells ]; then # Solus OS
      shells_file=/usr/share/defaults/etc/shells
    else
      fmt_error "could not find /etc/shells file. Change your default shell manually."
      return
    fi

    # Get the path to the right zsh binary
    # 1. Use the most preceding one based on $PATH, then check that it's in the shells file
    # 2. If that fails, get a zsh path from the shells file, then check it actually exists
    if ! zsh=$(command -v zsh) || ! grep -qx "$zsh" "$shells_file"; then
      if ! zsh=$(grep '^/.*/zsh$' "$shells_file" | tail -n 1) || [ ! -f "$zsh" ]; then
        fmt_error "no zsh binary found or not present in '$shells_file'"
        fmt_error "change your default shell manually."
        return
      fi
    fi
  fi

  # We're going to change the default shell, so back up the current one
  if [ -n "$SHELL" ]; then
    echo "$SHELL" > ~/.shell.pre-oh-my-zsh
  else
    grep "^$USERNAME:" /etc/passwd | awk -F: '{print $7}' > ~/.shell.pre-oh-my-zsh
  fi

  # Actually change the default shell to zsh
  if ! chsh -s "$zsh"; then
    fmt_error "chsh command unsuccessful. Change your default shell manually."
  else
    export SHELL="$zsh"
    echo "${GREEN}Shell successfully changed to '$zsh'.${RESET}"
  fi

  echo
}

# shellcheck disable=SC2183  # printf string has more %s than arguments ($RAINBOW expands to multiple arguments)
print_success() {
  printf '%s         %s__      %s           %s        %s       %s     %s__   %s\n'      $RAINBOW $RESET
  printf '%s  ____  %s/ /_    %s ____ ___  %s__  __  %s ____  %s_____%s/ /_  %s\n'      $RAINBOW $RESET
  printf '%s / __ \\%s/ __ \\  %s / __ `__ \\%s/ / / / %s /_  / %s/ ___/%s __ \\ %s\n'  $RAINBOW $RESET
  printf '%s/ /_/ /%s / / / %s / / / / / /%s /_/ / %s   / /_%s(__  )%s / / / %s\n'      $RAINBOW $RESET
  printf '%s\\____/%s_/ /_/ %s /_/ /_/ /_/%s\\__, / %s   /___/%s____/%s_/ /_/  %s\n'    $RAINBOW $RESET
  printf '%s    %s        %s           %s /____/ %s       %s     %s          %s....is now installed!%s\n' $RAINBOW $GREEN $RESET
  printf '\n'
  printf '\n'
  printf "%s %s %s\n" "Before you scream ${BOLD}${YELLOW}Oh My Zsh!${RESET} look over the" \
    "$(fmt_code "$(fmt_link ".zshrc" "file://$HOME/.zshrc" --text)")" \
    "file to select plugins, themes, and options."
  printf '\n'
  printf '%s\n' "• Follow us on Twitter: $(fmt_link @ohmyzsh https://twitter.com/ohmyzsh)"
  printf '%s\n' "• Join our Discord community: $(fmt_link "Discord server" https://discord.gg/ohmyzsh)"
  printf '%s\n' "• Get stickers, t-shirts, coffee mugs and more: $(fmt_link "Planet Argon Shop" https://shop.planetargon.com/collections/oh-my-zsh)"
  printf '%s\n' $RESET
}

main() {
  # Run as unattended if stdin is not a tty
  if [ ! -t 0 ]; then
    RUNZSH=no
    CHSH=no
  fi

  # Parse arguments
  while [ $# -gt 0 ]; do
    case $1 in
      --unattended) RUNZSH=no; CHSH=no ;;
      --skip-chsh) CHSH=no ;;
      --keep-zshrc) KEEP_ZSHRC=yes ;;
    esac
    shift
  done

  setup_color

  if ! command_exists zsh; then
    echo "${YELLOW}Zsh is not installed.${RESET} Please install zsh first."
    exit 1
  fi

  if [ -d "$ZSH" ]; then
    echo "${YELLOW}The \$ZSH folder already exists ($ZSH).${RESET}"
    if [ "$custom_zsh" = yes ]; then
      cat <<EOF
You ran the installer with the \$ZSH setting or the \$ZSH variable is
exported. You have 3 options:
1. Unset the ZSH variable when calling the installer:
   $(fmt_code "ZSH= sh install.sh")
2. Install Oh My Zsh to a directory that doesn't exist yet:
   $(fmt_code "ZSH=path/to/new/ohmyzsh/folder sh install.sh")
3. (Caution) If the folder doesn't contain important information,
   you can just remove it with $(fmt_code "rm -r $ZSH")
EOF
    else
      echo "You'll need to remove it if you want to reinstall."
    fi
    exit 1
  fi

  setup_ohmyzsh
  setup_zshrc
  setup_shell

  print_success

  if [ $RUNZSH = no ]; then
    echo "${YELLOW}Run zsh to try it out.${RESET}"
    exit
  fi

  # exec zsh -l
}

main "$@"