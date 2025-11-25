# AUTOMATICALLY GENERATED FILE. EDIT ONLY THE SOURCE FILES AND THEN COMPILE.
# DO NOT DIRECTLY EDIT THIS FILE!

# MIT License
#
# Copyright (c) 2019-2025 Eric Nielsen and contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

if [[ -z ${ZSH_VERSION} ]]; then
  echo 'You must use zsh to run install.zsh' >&2
  exit 1
fi

emulate -L zsh -o EXTENDED_GLOB

_replace_home() {
  local abs_path=${1:A}
  local suffix=${abs_path#${${ZDOTDIR:-${HOME}}:A}}
  if [[ ${abs_path} != ${suffix} ]]; then
    print -R '${ZDOTDIR:-${HOME}}'${suffix}
  else
    print -R ${1}
  fi
}

if [[ -z ${NO_COLOR} && -t 1 ]]; then
  readonly ZNORMAL=$'\E[0m' ZBOLD=$'\E[1m' ZRED=$'\E[31m' ZNORMALRED=$'\E[0;31m' ZGREEN=$'\E[32m' ZYELLOW=$'\E[33m' ZNORMALYELLOW=$'\E[0;33m'
else
  readonly ZNORMAL= ZBOLD= ZRED= ZNORMALRED= ZGREEN= ZYELLOW= ZNORMALYELLOW=
fi
readonly ZERROR="${ZRED}x " ZOKAY="${ZGREEN}) ${ZNORMAL}" ZWARN="${ZYELLOW}! "
typeset -A ZTEMPLATES
ZIM_HOME_STR='${ZDOTDIR:-${HOME}}/.zim'

print "${ZBOLD},_____________  ,___________${ZNORMAL}
${ZBOLD}|__, | | , , |  | ,__| | | |${ZNORMAL}
${ZBOLD}  / /| | | | |${ZRED}()${ZNORMAL}${ZBOLD}| |__| | | |${ZNORMAL}
${ZBOLD} / / |-| | | |  | ,_|| | | |${ZNORMAL}
${ZBOLD}/ /__| | | | |${ZRED}()${ZNORMAL}${ZBOLD}| |  | | | |${ZNORMAL}
${ZBOLD};____|_|_|_|_|  |_|  |_____|${ZNORMAL}
"

# Check Zsh version
autoload -Uz is-at-least && if ! is-at-least 5.2; then
  print -u2 -R "${ZERROR}You're using Zsh version ${ZSH_VERSION} and versions < 5.2 are not supported. Please update your Zsh.${ZNORMAL}"
  return 1
fi
print -R "${ZOKAY}Using Zsh version ${ZSH_VERSION}"

# Check ZIM_HOME
if (( ! ${+ZIM_HOME} )); then
  print ${ZOKAY}'ZIM_HOME not set, using the default one.'
  ZIM_HOME=${(e)ZIM_HOME_STR}
elif [[ ${ZIM_HOME} == ${(e)ZIM_HOME_STR} ]]; then
  print ${ZOKAY}'Your ZIM_HOME is the default one.'
else
  ZIM_HOME_STR=$(_replace_home ${ZIM_HOME})
  print -R "${ZOKAY}Your ZIM_HOME is customized to ${ZBOLD}${ZIM_HOME_STR}${ZNORMAL}"
fi
if [[ -e ${ZIM_HOME} ]]; then
  if [[ -n ${ZIM_HOME}(#qN/^F) ]]; then
    print ${ZOKAY}'ZIM_HOME already exists, but is empty.'
  else
    print -u2 -R "${ZERROR}${ZBOLD}${ZIM_HOME}${ZNORMALRED} already exists. Please set ZIM_HOME to the path where you want to install Zim Framework.${ZNORMAL}"
    return 1
  fi
fi

# Check if Zsh is the default shell
if [[ ${SHELL:t} == zsh ]]; then
  print ${ZOKAY}'Zsh is your default shell.'
else
  readonly ZPATH==zsh
  if command chsh -s ${ZPATH}; then
    print -R "${ZOKAY}Changed your default shell to ${ZBOLD}${ZPATH}${ZNORMAL}"
  else
    print -u2 -R "${ZWARN}Could not change your default shell to ${ZBOLD}${ZPATH}${ZNORMALYELLOW}. Please manually change it later.${ZNORMAL}"
  fi
fi

# Check if other frameworks are enabled
for ZDOTFILE in /etc/(zsh/)#(z|.z)(shenv|profile|shrc|login)(N) ${ZDOTDIR:-${HOME}}/.z(shenv|profile|shrc|login)(N); do
  if grep -Eq "^[^#]*(\\bsource|\\.).*(${ZIM_HOME:t}|\\\$[{]?ZIM_HOME[}]?)/init.zsh\\b" ${ZDOTFILE}; then
    print -u2 "${ZERROR}You seem to have Zim Framework already installed in ${ZBOLD}${ZDOTFILE}${ZNORMALRED}. Please uninstall it first.${ZNORMAL}"
    return 1
  fi
  if grep -Eq '^[^#]*(\bsource|\.).*prezto/init.zsh\b' ${ZDOTFILE}; then
    print -u2 "${ZWARN}You seem to have prezto enabled in ${ZBOLD}${ZDOTFILE}${ZNORMALYELLOW}. Please disable it.${ZNORMAL}"
  fi
  if grep -Eq '^[^#]*(\bsource|\.).*/oh-my-zsh.sh\b' ${ZDOTFILE}; then
    print -u2 "${ZWARN}You seem to have oh-my-zsh enabled in ${ZBOLD}${ZDOTFILE}${ZNORMALYELLOW}. Please disable it.${ZNORMAL}"
  fi
  if grep -Eq '^[^#]*\bantibody\s+bundle\b' ${ZDOTFILE}; then
    print -u2 "${ZWARN}You seem to have antibody enabled in ${ZBOLD}${ZDOTFILE}${ZNORMALYELLOW}. Please disable it.${ZNORMAL}"
  fi
  if grep -Eq '^[^#]*\bantigen\s+apply\b' ${ZDOTFILE}; then
    print -u2 "${ZWARN}You seem to have antigen enabled in ${ZBOLD}${ZDOTFILE}${ZNORMALYELLOW}. Please disable it.${ZNORMAL}"
  fi
  if grep -Eq '^[^#]*(\bsource|\.).*/zgen.zsh\b' ${ZDOTFILE}; then
    print -u2 "${ZWARN}You seem to have zgen enabled in ${ZBOLD}${ZDOTFILE}${ZNORMALYELLOW}. Please disable it.${ZNORMAL}"
  fi
  if grep -Eq '^[^#]*\bzplug\s+load\b' ${ZDOTFILE}; then
    print -u2 "${ZWARN}You seem to have zplug enabled in ${ZBOLD}${ZDOTFILE}${ZNORMALYELLOW}. Please disable it.${ZNORMAL}"
  fi
  if grep -Eq '^[^#]*\b(function\s+grml_vcs_info_toggle_colour\b|grml_vcs_info_toggle_colour\s*\(\s*\))' ${ZDOTFILE}; then
    print -u2 "${ZWARN}You seem to have grml installed in ${ZBOLD}${ZDOTFILE}${ZNORMALYELLOW}. Please uninstall it.${ZNORMAL}"
  fi
  if grep -Eq '^[^#]*\bcompinit\b' ${ZDOTFILE}; then
    print -u2 "${ZWARN}You seem to be already calling ${ZBOLD}compinit${ZNORMALYELLOW} in ${ZBOLD}${ZDOTFILE}${ZNORMALYELLOW}. Please remove it, because Zim Framework's completion module will call ${ZBOLD}compinit${ZNORMALYELLOW} for you.${ZNORMAL}"
  fi
  if grep -Eq '^[^#]*\bpromptinit\b' ${ZDOTFILE}; then
    print -u2 "${ZWARN}You seem to be calling ${ZBOLD}promptinit${ZNORMALYELLOW} in ${ZBOLD}${ZDOTFILE}${ZNORMALYELLOW}. Please remove it, because Zim Framework already has a prompt theme for you that does not require ${ZBOLD}promptinit${ZNORMALYELLOW}.${ZNORMAL}"
  fi
done

# Download zimfw script
readonly ZTARGET=${ZIM_HOME}/zimfw.zsh
if (
  command mkdir -p ${ZIM_HOME} || return 1
  readonly ZURL=https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  if [[ ${+commands[curl]} -ne 0 && -x ${commands[curl]} ]]; then
    command curl -fsSL -o ${ZTARGET} ${ZURL} || return 1
  elif [[ ${+commands[wget]} -ne 0 && -x ${commands[wget]} ]]; then
    command wget -nv -O ${ZTARGET} ${ZURL} || return 1
  else
    print -u2 "${ZERROR}Either ${ZBOLD}curl${ZNORMALRED} or ${ZBOLD}wget${ZNORMALRED} are required to download Zim Framework script.${ZNORMAL}"
    return 1
  fi
); then
  print -R "${ZOKAY}Downloaded Zim Framework script to ${ZBOLD}${ZTARGET}${ZNORMAL}"
else
  command rm -rf ${ZIM_HOME}
  print -u2 -R "${ZERROR}Could not download Zim Framework script to ${ZBOLD}${ZTARGET}${ZNORMALRED}${ZNORMAL}"
  return 1
fi

# Prepend templates
ZTEMPLATES[zimrc]="# Start configuration added by Zim Framework install {{{
#
# This is not sourced during shell startup and is only used to configure zimfw.
#

#
# Modules
#

# Sets sane Zsh built-in environment options.
zmodule environment
# Provides handy git aliases and functions.
zmodule git
# Applies correct bindkeys for input events.
zmodule input
# Sets a custom terminal title.
zmodule termtitle
# Utility aliases and functions. Adds colour to ls, grep and less.
zmodule utility

# <-- Normally new modules should be added here. Check each module documentation
# for any caveats.

#
# Prompt
#

# Exposes how long the last command took to run to prompts.
zmodule duration-info
# Exposes git repository status information to prompts.
zmodule git-info
# A heavily reduced, ASCII-only version of the Spaceship and Starship prompts.
zmodule asciiship

#
# Completion
#

# Additional completion definitions for Zsh.
zmodule zsh-users/zsh-completions --fpath src
# Enables and configures smart and extensive tab completion, must be sourced
# after all modules that add completion definitions.
zmodule completion

#
# Modules that must be initialized last
#

# Fish-like syntax highlighting for Zsh, must be sourced after completion.
zmodule zsh-users/zsh-syntax-highlighting
# Fish-like history search for Zsh, must be sourced after
# zsh-users/zsh-syntax-highlighting. Bind keyboard shortcuts in your ~/.zshrc:
# https://github.com/zsh-users/zsh-history-substring-search/blob/master/README.md#usage
zmodule zsh-users/zsh-history-substring-search
# Fish-like autosuggestions for Zsh. Add the following to your ~/.zshrc to boost
# performance: ZSH_AUTOSUGGEST_MANUAL_REBIND=1
zmodule zsh-users/zsh-autosuggestions
# }}} End configuration added by Zim Framework install
"
ZTEMPLATES[zshrc]="# Start configuration added by Zim Framework install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (\`-e\`) or vi (\`-v\`)
bindkey -e

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=\${WORDCHARS//[\\/]}

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append \`../\` to your input for each \`.\` you type after an initial \`..\`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZIM_HOME_STR}
# Download zimfw plugin manager if missing.
if [[ ! -e \${ZIM_HOME}/zimfw.zsh ]]; then
  if (( \${+commands[curl]} )); then
    curl -fsSL --create-dirs -o \${ZIM_HOME}/zimfw.zsh \\
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p \${ZIM_HOME} && wget -nv -O \${ZIM_HOME}/zimfw.zsh \\
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# Install missing modules, and update \${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! \${ZIM_HOME}/init.zsh -nt \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]]; then
  source \${ZIM_HOME}/zimfw.zsh init
fi
# Initialize modules.
source \${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' \${terminfo[kcuu1]}) bindkey \${key} history-substring-search-up
for key ('^[[B' '^N' \${terminfo[kcud1]}) bindkey \${key} history-substring-search-down
for key ('k') bindkey -M vicmd \${key} history-substring-search-up
for key ('j') bindkey -M vicmd \${key} history-substring-search-down
unset key
# }}} End configuration added by Zim Framework install
"
for ZTEMPLATE in ${(k)ZTEMPLATES}; do
  USER_FILE=${${:-${ZDOTDIR:-${HOME}}/.${ZTEMPLATE}}:A}
  if ERR=$(command mv -f =(
    print -R ${ZTEMPLATES[${ZTEMPLATE}]}
    if [[ -e ${USER_FILE} ]] cat ${USER_FILE}
  ) ${USER_FILE} 2>&1); then
    print -R "${ZOKAY}Prepended Zim Framework template to ${ZBOLD}${USER_FILE}${ZNORMAL}"
  else
    print -u2 -lR "${ZERROR}Error prepending Zim Framework template to ${ZBOLD}${USER_FILE}${ZNORMAL}" ${ERR}
    return 1
  fi
done

if ERR=$(source ${ZIM_HOME}/zimfw.zsh init -q 2>&1); then
  print ${ZOKAY}'Installed modules.'
else
  print -u2 -lR ${ERR} "${ZERROR}Could not install modules.${ZNORMAL}"
  return 1
fi

print 'All done. Enjoy your Zsh IMproved! Restart your terminal for changes to take effect.'

