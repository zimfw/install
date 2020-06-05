# AUTOMATICALLY GENERATED FILE. EDIT ONLY THE SOURCE FILES AND THEN COMPILE.
# DO NOT DIRECTLY EDIT THIS FILE!

# MIT License
#
# Copyright (c) 2019-2020 Eric Nielsen and contributors
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
  print -u2 -P '%F{red}x You must use zsh to run install.zsh%f'
  return 1
fi

emulate -L zsh

_replace_home() {
  local abs_path=${1:A}
  local suffix=${abs_path#${${ZDOTDIR:-${HOME}}:A}}
  if [[ ${abs_path} != ${suffix} ]]; then
    print -R '${ZDOTDIR:-${HOME}}'${suffix}
  else
    print -R ${1}
  fi
}

setopt LOCAL_OPTIONS EXTENDED_GLOB
typeset -A ZTEMPLATES
readonly CLEAR_LINE=$'\E[2K\r'
ZIM_HOME_STR='${ZDOTDIR:-${HOME}}/.zim'

# Check if git is installed
if (( ${+commands[git]} )); then
  print -P '%F{green})%f Git is installed.'
else
  print -u2 -P '%F{red}x Git is required to install Zim.%f'
  return 1
fi

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
readonly ZSHRC=${ZDOTDIR:-${HOME}}/.zshrc
if [[ -e ${ZSHRC} ]]; then
  if grep -Eq '^[^#]*(source|\.).*(zim(fw)?|\$[{]?ZIM_HOME[}]?)/init.zsh' ${ZSHRC}; then
    print -u2 -P '%F{red}x You seem to have Zim installed already. Please uninstall it first.%f'
    return 1
  fi
  if grep -Eq '^[^#]*(source|\.).*prezto/init.zsh' ${ZSHRC}; then
    print -u2 -P '%F{yellow}! You seem to have prezto enabled. Please disable it.%f'
  elif grep -Eq '^[^#]*(source|\.).*/oh-my-zsh.sh' ${ZSHRC}; then
    print -u2 -P '%F{yellow}! You seem to have oh-my-zsh enabled. Please disable it.%f'
  elif grep -Eq '^[^#]*antibody bundle' ${ZSHRC}; then
    print -u2 -P '%F{yellow}! You seem to have antibody enabled. Please disable it.%f'
  elif grep -Eq '^[^#]*antigen apply' ${ZSHRC}; then
    print -u2 -P '%F{yellow}! You seem to have antigen enabled. Please disable it.%f'
  elif grep -Eq '^[^#]*(source|\.).*/zgen.zsh' ${ZSHRC}; then
    print -u2 -P '%F{yellow}! You seem to have zgen enabled. Please disable it.%f'
  elif grep -Eq '^[^#]*zplug load' ${ZSHRC}; then
    print -u2 -P '%F{yellow}! You seem to have zplug enabled. Please disable it.%f'
  else
    print -P '%F{green})%f No other Zsh frameworks detected.'
  fi
fi

# Download zimfw script
local -r ztarget=${ZIM_HOME}/zimfw.zsh
if (
  command mkdir -p ${ZIM_HOME} || return 1
  local -r zurl=https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  if (( ${+commands[curl]} )); then
    command curl -fsSL -o ${ztarget} ${zurl} || return 1
  elif (( ${+commands[wget]} )); then
    command wget -nv -O ${ztarget} ${zurl} || return 1
  else
    print -u2 -P '%F{red}x Either %Bcurl%b or %Bwget%b are required to download the Zim script.%f'
    return 1
  fi
); then
  print -PR "%F{green})%f Downloaded the Zim script to %B${ztarget}%b"
else
  command rm -rf ${ZIM_HOME}
  print -u2 -PR "%F{red}x Could not download the Zim script to %B${ztarget}%b%f"
  return 1
fi

# Prepend templates
ZTEMPLATES[zimrc]="# Start configuration added by Zim install {{{
# -------
# Modules
# -------

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
# Exposes git repository status information to prompts.
zmodule git-info
# A customizable version of steeef's prompt theme.
zmodule steeef

# Additional completion definitions for Zsh.
zmodule zsh-users/zsh-completions
# Enables and configures smart and extensive tab completion.
# completion must be sourced after zsh-users/zsh-completions
zmodule completion
# Fish-like autosuggestions for Zsh.
zmodule zsh-users/zsh-autosuggestions
# Fish-like syntax highlighting for Zsh.
# zsh-users/zsh-syntax-highlighting must be sourced after completion
zmodule zsh-users/zsh-syntax-highlighting
# Fish-like history search (up arrow) for Zsh.
# zsh-users/zsh-history-substring-search must be sourced after zsh-users/zsh-syntax-highlighting
zmodule zsh-users/zsh-history-substring-search
# }}} End configuration added by Zim install
"
ZTEMPLATES[zlogin]="# Start configuration added by Zim install {{{
#
# User configuration sourced by login shells
#

# Initialize Zim
source \${ZIM_HOME}/login_init.zsh -q &!
# }}} End configuration added by Zim install
"
ZTEMPLATES[zshenv]="# Start configuration added by Zim install {{{
#
# User configuration sourced by all invocations of the shell
#

# Define Zim location
: \${ZIM_HOME=${ZIM_HOME_STR}}
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


# --------------------
# Module configuration
# --------------------

#
# completion
#

# Set a custom path for the completion dump file.
# If none is provided, the default \${ZDOTDIR:-\${HOME}}/.zcompdump is used.
#zstyle ':zim:completion' dumpfile \"\${ZDOTDIR:-\${HOME}}/.zcompdump-\${ZSH_VERSION}\"

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

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=10'

# ------------------
# Initialize modules
# ------------------

if [[ \${ZIM_HOME}/init.zsh -ot \${ZDOTDIR:-\${HOME}}/.zimrc ]]; then
  # Update static initialization script if it's outdated, before sourcing it
  source \${ZIM_HOME}/zimfw.zsh init -q
fi
source \${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Bind up and down keys
zmodload -F zsh/terminfo +p:terminfo
if [[ -n \${terminfo[kcuu1]} && -n \${terminfo[kcud1]} ]]; then
  bindkey \${terminfo[kcuu1]} history-substring-search-up
  bindkey \${terminfo[kcud1]} history-substring-search-down
fi

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
# }}} End configuration added by Zim install
"
for ZTEMPLATE in ${(k)ZTEMPLATES}; do
  USER_FILE=${ZDOTDIR:-${HOME}}/.${ZTEMPLATE}
  if [[ -e ${USER_FILE} ]]; then
    USER_FILE=${USER_FILE:A}
    if ERR=$(command mv =(
      print -R ${ZTEMPLATES[${ZTEMPLATE}]}
      cat ${USER_FILE}
    ) ${USER_FILE} 2>&1); then
      print -PR "%F{green})%f Prepended Zim template to %B${USER_FILE}%b"
    else
      print -u2 -PR "%F{red}x Error prepending Zim template to %B${USER_FILE}%b%f"$'\n'${ERR}
      return 1
    fi
  else
    if ERR=$(print -R ${ZTEMPLATES[${ZTEMPLATE}]} > ${USER_FILE}); then
      print -PR "%F{green})%f Copied Zim template to %B${USER_FILE}%b"
    else
      print -u2 -PR "%F{red}x Error copying Zim template to %B${USER_FILE}%b%f"$'\n'${ERR}
      return 1
    fi
  fi
done

print -n "Installing modules ..."
if ERR=$(source ${ZIM_HOME}/zimfw.zsh install -q 2>&1); then
  print -P ${CLEAR_LINE}'%F{green})%f Installed modules.'
else
  print -u2 -PR ${CLEAR_LINE}${ERR}$'\n''%F{red}x Could not install modules.%f'
  return 1
fi

print -n "Initializing Zim ..."
source =( print -R ${ZTEMPLATES[zshrc]} )
source =( print -R ${ZTEMPLATES[zlogin]} )
print -P ${CLEAR_LINE}'All done. Enjoy your Zsh IMproved! Restart your terminal for changes to take effect.'

