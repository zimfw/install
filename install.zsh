# AUTOMATICALLY GENERATED FILE. EDIT ONLY THE SOURCE FILES AND THEN COMPILE.
# DO NOT DIRECTLY EDIT THIS FILE!

# MIT License
#
# Copyright (c) 2019-2022 Eric Nielsen and contributors
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

typeset -A ZTEMPLATES
readonly CLEAR_LINE=$'\E[2K\r'
ZIM_HOME_STR='${ZDOTDIR:-${HOME}}/.zim'

# Check Zsh version
autoload -Uz is-at-least && if ! is-at-least 5.2; then
  print -u2 -PR "%F{red}x You're using Zsh version ${ZSH_VERSION} and versions < 5.2 are not supported. Please update your Zsh.%f"
  return 1
fi
print -PR "%F{green})%f Using Zsh version ${ZSH_VERSION}"

# Check ZIM_HOME
if (( ! ${+ZIM_HOME} )); then
  print -P '%F{green})%f ZIM_HOME not set, using the default one.'
  ZIM_HOME=${(e)ZIM_HOME_STR}
elif [[ ${ZIM_HOME} == ${(e)ZIM_HOME_STR} ]]; then
  print -P '%F{green})%f Your ZIM_HOME is the default one.'
else
  ZIM_HOME_STR=$(_replace_home ${ZIM_HOME})
  print -PR "%F{green})%f Your ZIM_HOME is customized to %B${ZIM_HOME_STR}%b"
fi
if [[ -e ${ZIM_HOME} ]]; then
  if [[ -n ${ZIM_HOME}(#qN/^F) ]]; then
    print -P '%F{green})%f ZIM_HOME already exists, but is empty.'
  else
    print -u2 -PR "%F{red}x %B${ZIM_HOME}%b already exists. Please set ZIM_HOME to the path where you want to install Zim.%f"
    return 1
  fi
fi

# Check if Zsh is the default shell
if [[ ${SHELL:t} == zsh ]]; then
  print -P '%F{green})%f Zsh is your default shell.'
else
  readonly ZPATH==zsh
  if command chsh -s ${ZPATH}; then
    print -PR "%F{green})%f Changed your default shell to %B${ZPATH}%b"
  else
    print -u2 -PR "%F{yellow}! Could not change your default shell to %B${ZPATH}%b. Please manually change it later.%f"
  fi
fi

# Check if other frameworks are enabled
for ZDOTFILE in /etc/(zsh/)#(z|.z)(shenv|profile|shrc|login)(N) ${ZDOTDIR:-${HOME}}/.z(shenv|profile|shrc|login)(N); do
  if grep -Eq "^[^#]*(\\bsource|\\.).*(${ZIM_HOME:t}|\\\$[{]?ZIM_HOME[}]?)/init.zsh\\b" ${ZDOTFILE}; then
    print -u2 -P "%F{red}x You seem to have Zim already installed in %B${ZDOTFILE}%b. Please uninstall it first.%f"
    return 1
  fi
  if grep -Eq '^[^#]*(\bsource|\.).*prezto/init.zsh\b' ${ZDOTFILE}; then
    print -u2 -P "%F{yellow}! You seem to have prezto enabled in %B${ZDOTFILE}%b. Please disable it.%f"
  fi
  if grep -Eq '^[^#]*(\bsource|\.).*/oh-my-zsh.sh\b' ${ZDOTFILE}; then
    print -u2 -P "%F{yellow}! You seem to have oh-my-zsh enabled in %B${ZDOTFILE}%b. Please disable it.%f"
  fi
  if grep -Eq '^[^#]*\bantibody\s+bundle\b' ${ZDOTFILE}; then
    print -u2 -P "%F{yellow}! You seem to have antibody enabled in %B${ZDOTFILE}%b. Please disable it.%f"
  fi
  if grep -Eq '^[^#]*\bantigen\s+apply\b' ${ZDOTFILE}; then
    print -u2 -P "%F{yellow}! You seem to have antigen enabled in %B${ZDOTFILE}%b. Please disable it.%f"
  fi
  if grep -Eq '^[^#]*(\bsource|\.).*/zgen.zsh\b' ${ZDOTFILE}; then
    print -u2 -P "%F{yellow}! You seem to have zgen enabled in %B${ZDOTFILE}%b. Please disable it.%f"
  fi
  if grep -Eq '^[^#]*\bzplug\s+load\b' ${ZDOTFILE}; then
    print -u2 -P "%F{yellow}! You seem to have zplug enabled in %B${ZDOTFILE}%b. Please disable it.%f"
  fi
  if grep -Eq '^[^#]*\b(function\s+grml_vcs_info_toggle_colour\b|grml_vcs_info_toggle_colour\s*\(\s*\))' ${ZDOTFILE}; then
    print -u2 -P "%F{yellow}! You seem to have grml installed in %B${ZDOTFILE}%b. Please uninstall it.%f"
  fi
  if grep -Eq '^[^#]*\bcompinit\b' ${ZDOTFILE}; then
    print -u2 -P "%F{yellow}! You seem to be already calling %Bcompinit%b in %B${ZDOTFILE}%b. Please remove it, because Zim's completion module will call %Bcompinit%b for you.%f"
  fi
  if grep -Eq '^[^#]*\bpromptinit\b' ${ZDOTFILE}; then
    print -u2 -P "%F{yellow}! You seem to be calling %Bpromptinit%b in %B${ZDOTFILE}%b. Please remove it, because Zim already has a prompt theme for you that does not require %Bpromptinit%b.%f"
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
    print -u2 -P '%F{red}x Either %Bcurl%b or %Bwget%b are required to download the Zim script.%f'
    return 1
  fi
); then
  print -PR "%F{green})%f Downloaded the Zim script to %B${ZTARGET}%b"
else
  command rm -rf ${ZIM_HOME}
  print -u2 -PR "%F{red}x Could not download the Zim script to %B${ZTARGET}%b%f"
  return 1
fi

# Prepend templates
ZTEMPLATES[zimrc]="# Start configuration added by Zim install {{{
#
# This is not sourced during shell startup, and it's only used to configure the
# zimfw plugin manager.
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

#
# Prompt
#

# Exposes to prompts how long the last command took to execute, used by asciiship.
zmodule duration-info
# Exposes git repository status information to prompts, used by asciiship.
zmodule git-info
# A heavily reduced, ASCII-only version of the Spaceship and Starship prompts.
zmodule asciiship

#
# Completion
#

# Additional completion definitions for Zsh.
zmodule zsh-users/zsh-completions --fpath src
# Enables and configures smart and extensive tab completion.
# completion must be sourced after all modules that add completion definitions.
zmodule completion

#
# Modules that must be initialized last
#

# Fish-like syntax highlighting for Zsh.
# zsh-users/zsh-syntax-highlighting must be sourced after completion
zmodule zsh-users/zsh-syntax-highlighting
# Fish-like history search (up arrow) for Zsh.
# zsh-users/zsh-history-substring-search must be sourced after zsh-users/zsh-syntax-highlighting
zmodule zsh-users/zsh-history-substring-search
# Fish-like autosuggestions for Zsh.
zmodule zsh-users/zsh-autosuggestions
# }}} End configuration added by Zim install
"
ZTEMPLATES[zshrc]="# Start configuration added by Zim install {{{
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

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
#zstyle ':zim:zmodule' use 'degit'

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
# }}} End configuration added by Zim install
"
for ZTEMPLATE in ${(k)ZTEMPLATES}; do
  USER_FILE=${${:-${ZDOTDIR:-${HOME}}/.${ZTEMPLATE}}:A}
  if ERR=$(command mv -f =(
    print -R ${ZTEMPLATES[${ZTEMPLATE}]}
    if [[ -e ${USER_FILE} ]] cat ${USER_FILE}
  ) ${USER_FILE} 2>&1); then
    print -PR "%F{green})%f Prepended Zim template to %B${USER_FILE}%b"
  else
    print -u2 -PlR "%F{red}x Error prepending Zim template to %B${USER_FILE}%b%f" ${ERR}
    return 1
  fi
done

print -n 'Installing modules ...'
if ERR=$(source ${ZIM_HOME}/zimfw.zsh init -q 2>&1); then
  print -P ${CLEAR_LINE}'%F{green})%f Installed modules.'
else
  print -u2 -PlR "${CLEAR_LINE}${ERR}" '%F{red}x Could not install modules.%f'
  return 1
fi

print -P ${CLEAR_LINE}'All done. Enjoy your Zsh IMproved! Restart your terminal for changes to take effect.'

