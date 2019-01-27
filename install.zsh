# AUTOMATICALLY GENERATED FILE. EDIT ONLY THE SOURCE FILES AND THEN COMPILE.
# DO NOT DIRECTLY EDIT THIS FILE!

if [[ -z ${ZSH_VERSION} ]]; then
  print -u2 -P '%F{red}✗ You must use zsh to run install.zsh'
  return 1
fi

emulate -L zsh

_replace_home() {
  local abs_path=${1:A}
  local suffix=${abs_path#${${ZDOTDIR:-${HOME}}:A}}
  if [[ ${abs_path} != ${suffix} ]]; then
    print '${ZDOTDIR:-${HOME}}'${suffix}
  else
    print ${1}
  fi
}

typeset -A ZTEMPLATES
CLEAR_LINE="\033[2K\r"
ZIM_HOME_STR='${ZDOTDIR:-${HOME}}/.zim'

# Check Zsh version
autoload -Uz is-at-least && if ! is-at-least 5.2; then
  print -u2 -P "%F{red}✗ You're using Zsh version ${ZSH_VERSION} and versions < 5.2 are not supported. Please update your Zsh.%f"
  return 1
fi
print -P "%F{green}✓%f Using Zsh version ${ZSH_VERSION}"

# Check ZIM_HOME
if (( ! ${+ZIM_HOME} )); then
  print -P '%F{green}✓%f ZIM_HOME not set, using the default one.'
  ZIM_HOME=${(e)ZIM_HOME_STR}
elif [[ ${ZIM_HOME} == ${(e)ZIM_HOME_STR} ]]; then
  print -P '%F{green}✓%f Your ZIM_HOME is the default one.'
else
  ZIM_HOME_STR=$(_replace_home ${ZIM_HOME})
  print -P "%F{green}✓%f Your ZIM_HOME is customized to ${ZIM_HOME_STR}"
fi
if [[ -e ${ZIM_HOME} ]]; then
  if (( $(command find ${ZIM_HOME} -type d -maxdepth 0 -empty | wc -l) )); then
    print -P "%F{green}✓%f ZIM_HOME already exists, but is empty."
  else
    print -u2 -P "%F{red}✗ ${ZIM_HOME} already exists. Please set ZIM_HOME to the path where you want to install Zim."
    return 1
  fi
fi

# Check if Zsh is the default shell
if [[ ${SHELL:t} == zsh ]]; then
  print -P '%F{green}✓%f Zsh is your default shell.'
else
  ZPATH==zsh
  command chsh -s ${ZPATH}
  if (( ? )); then
    print -u2 -P "%F{red}✗ Could not change your default shell to ${ZPATH}. Please manually change it later."
  else
    print -P "%F{green}✓%f Changed your default shell to ${ZPATH}"
  fi
fi

# Check if other frameworks are enabled
ZSHRC=${ZDOTDIR:-${HOME}}/.zshrc
if [[ -e ${ZSHRC} ]]; then
  if grep -Eq '^[^#]*(source|\.).*prezto/init.zsh' ${ZSHRC}; then
    print -u2 -P '%F{red}✗ You seem to have prezto enabled. Please disable it.%f'
  elif grep -Eq '^[^#]*(source|\.).*/oh-my-zsh.sh' ${ZSHRC}; then
    print -u2 -P '%F{red}✗ You seem to have oh-my-zsh enabled. Please disable it.%f'
  elif grep -Eq '^[^#]*antibody bundle' ${ZSHRC}; then
    print -u2 -P '%F{red}✗ You seem to have antibody enabled. Please disable it.%f'
  elif grep -Eq '^[^#]*antigen apply' ${ZSHRC}; then
    print -u2 -P '%F{red}✗ You seem to have antigen enabled. Please disable it.%f'
  elif grep -Eq '^[^#]*(source|\.).*/zgen.zsh' ${ZSHRC}; then
    print -u2 -P '%F{red}✗ You seem to have zgen enabled. Please disable it.%f'
  elif grep -Eq '^[^#]*zplug load' ${ZSHRC}; then
    print -u2 -P '%F{red}✗ You seem to have zplug enabled. Please disable it.%f'
  else
    print -P '%F{green}✓%f No other Zsh frameworks detected.'
  fi
fi

# Download zimfw script
if (){
  command mkdir -p ${ZIM_HOME} || return 1
  {
    local zscript=${ZIM_HOME}/zimfw.zsh
    local zurl=https://raw.githubusercontent.com/zimfw/zimfw/develop/zimfw.zsh
    if (( ${+commands[wget]} )); then
      command wget -nv ${1} -O ${zscript} ${zurl} || return 1
    elif (( ${+commands[curl]} )); then
      command curl -fsSL -o ${zscript} ${zurl} || return 1
    else
      print -u2 -P "%F{red}✗ Either %Bwget%b or %Bcurl%b are required to download the Zim script.%f"
      return 1
    fi
  } always {
    (( ? )) && command rm -rf ${ZIM_HOME}
  }
}; then
  print -P "%F{green}✓%f Downloaded the Zim script to ${ZIM_HOME_STR}"
else
  print -u2 -P "%F{red}✗ Could not download the Zim script to ${ZIM_HOME_STR}%f"
  return 1
fi

# Prepend templates
ZTEMPLATES[zimrc]="################
# ZIM SETTINGS #
################

# Set input mode to 'emacs' (default) or 'vi'.
#zstyle ':zim:input' mode 'vi'

# Select what modules you would like enabled. Modules are sourced in the order given.
zstyle ':zim' modules \
    directory environment git git-info history input utility \
    steeef \
    zsh-completions completion \
    zsh-autosuggestions zsh-syntax-highlighting history-substring-search

# Modules setup configuration.
# See https://github.com/zimfw/zimfw/blob/develop/README.md#module-customization
zstyle ':zim:module' zsh-completions 'url' 'zsh-users/zsh-completions'
zstyle ':zim:module' zsh-autosuggestions 'url' 'zsh-users/zsh-autosuggestions'
zstyle ':zim:module' zsh-syntax-highlighting 'url' 'zsh-users/zsh-syntax-highlighting'

###################
# MODULE SETTINGS #
###################

#
# completion
#

# Set a custom path for the completion dump file.
# If none is provided, the default \${ZDOTDIR:-\${HOME}}/.zcompdump is used.
#zstyle ':zim:completion' dumpfile \"\${ZDOTDIR:-\${HOME}}/.zcompdump-\${ZSH_VERSION}\"

#
# environment
#

# Set the string below to the desired terminal title format string.
# The terminal title is redrawn upon directory change, however, variables like
# \${PWD} are only evaluated once. Use prompt expansion strings for dynamic data.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# For example, '%n@%m: %1~' corresponds to 'username@host: /current/directory'.
#zstyle ':zim:environment' termtitle '%n@%m: %1~'

#
# history
#

# Save the history in a custom file path.
# If none is provided, the default \${ZDOTDIR:-\${HOME}}/.zhistory is used.
#HISTFILE=\${ZDOTDIR:-\${HOME}}/.zsh_history

#
# input
#

# Enable double-dot expansion.
# This appends '../' to your input for each '.' you type after an initial '..'
#zstyle ':zim:input' double-dot-expand yes

#
# utility
#

# Enable spelling correction prompts.
# See http://zsh.sourceforge.net/Doc/Release/Options.html#index-CORRECT
#setopt CORRECT

# Set a custom spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

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
"
ZTEMPLATES[zlogin]="#
# User configuration sourced by login shells
#

# Initialize Zim
zimfw login-init -q &!
"
ZTEMPLATES[zshrc]="#
# User configuration sourced by interactive shells
#

# Define Zim location
ZIM_HOME=${ZIM_HOME_STR}

# Start Zim
[[ -s \${ZIM_HOME}/zimfw.zsh ]] && source \${ZIM_HOME}/zimfw.zsh
"
for ZTEMPLATE in ${(k)ZTEMPLATES}; do
  USER_FILE=${ZDOTDIR:-${HOME}}/.${ZTEMPLATE}
  if [[ -e ${USER_FILE} ]]; then
    USER_FILE=${USER_FILE:A}
    USER_FILE_STR=$(_replace_home ${USER_FILE})
    if ERR=$(print ${ZTEMPLATES[${ZTEMPLATE}]} | cat - ${USER_FILE} > ${USER_FILE}.tmp && \
        command mv ${USER_FILE}{.tmp,} 2>&1); then
      print -P "%F{green}✓%f Prepended Zim template to ${USER_FILE_STR}"
    else
      print -u2 -P "%F{red}✗ Error prepending Zim template to ${USER_FILE_STR}%f\n${ERR}"
    fi
  else
    USER_FILE_STR=$(_replace_home ${USER_FILE})
    if ERR=$(print ${ZTEMPLATES[${ZTEMPLATE}]} > ${USER_FILE}); then
      print -P "%F{green}✓%f Copied Zim template to ${USER_FILE_STR}"
    else
      print -u2 -P "%F{red}✗ Error copying Zim template to ${USER_FILE_STR}%f\n${ERR}"
    fi
  fi
done

print -n "Installing modules …"
# Will complain that modules are not installed at first, so silence that.
source ${ZIM_HOME}/zimfw.zsh &>/dev/null
if ERR=$(zimfw install -q 2>&1); then
  print -P "${CLEAR_LINE}%F{green}✓%f Installed modules."
else
  print -u2 -P "${CLEAR_LINE}${ERR}\n%F{red}✗ Could not install modules.%f"
fi

print -n "Compiling Zsh scripts …"
if ERR=$(zimfw compile -q 2>&1); then
  print -P "${CLEAR_LINE}%F{green}✓%f Compiled Zsh scripts."
else
  print -u2 -P "${CLEAR_LINE}%F{red}✗ Error compiling Zsh scripts.%f\n${ERR}"
fi

