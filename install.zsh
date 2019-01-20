if [[ -z ${ZSH_VERSION} ]]; then
  print -P '%F{red}✗ You must use zsh to run install.zsh' >&2
  return 1
fi

emulate -L zsh

# Check Zsh version
autoload -Uz is-at-least && if ! is-at-least 5.2; then
  print -P "%F{red}✗You're using Zsh version ${ZSH_VERSION} and versions < 5.2 are not supported. Please update your Zsh.%f" >&2
  return 1
fi
print -P "%F{green}✓%f Using Zsh version ${ZSH_VERSION}"

{
_replace_prefix() {
  local suffix=${2#${(e)1}}
  if [[ ${2} != ${suffix} ]]; then
    print ${1}${suffix}
  else
    print ${2}
  fi
}

# Check ZIM_HOME
local home_str='${ZDOTDIR:-${HOME}}'
local zim_home_str=${home_str}/.zim
if (( ! ${+ZIM_HOME} )); then
  print -P '%F{green}✓%f ZIM_HOME not set, using the default one.'
  ZIM_HOME=${(e)zim_home_str}
elif [[ ${ZIM_HOME} == ${(e)zim_home_str} ]]; then
  print -P '%F{green}✓%f Your ZIM_HOME is the default one.'
else
  zim_home_str=$(_replace_prefix ${home_str} ${ZIM_HOME})
  print -P "%F{green}✓%f Your ZIM_HOME is customized to ${zim_home_str}"
fi
if [[ -e ${ZIM_HOME} ]]; then
  print -P "%F{red}✗ ${ZIM_HOME} already exists. Please set ZIM_HOME to the path where you want to install Zim." >&2
  return 1
fi

# Check if Zsh is the default shell
if [[ ${SHELL:t} == zsh ]]; then
  print -P '%F{green}✓%f Zsh is your default shell.'
else
  local zpath==zsh
  command chsh -s ${zpath}
  if (( ? )); then
    print -P "%F{red}✗ Could not change your default shell to ${zpath}. Please manually change it later." >&2
  else
    print -P "%F{green}✓%f Changed your default shell to ${zpath}"
  fi
fi

# Check if other frameworks are enabled
local zshrc=${(e)home_str}/.zshrc
if [[ -e ${zshrc} ]]; then
  if grep -Eq '^[^#]*(source|\.).*prezto/init.zsh' ${zshrc}; then
    print -P '%F{red}✗ You seem to have prezto enabled. Please disable it.%f' >&2
  elif grep -Eq '^[^#]*(source|\.).*/oh-my-zsh.sh' ${zshrc}; then
    print -P '%F{red}✗ You seem to have oh-my-zsh enabled. Please disable it.%f' >&2
  elif grep -Eq '^[^#]*antigen apply' ${zshrc}; then
    print -P '%F{red}✗ You seem to have antigen enabled. Please disable it.%f' >&2
  elif grep -Eq '^[^#]*(source|\.).*/zgen.zsh' ${zshrc}; then
    print -P '%F{red}✗ You seem to have zgen enabled. Please disable it.%f' >&2
  elif grep -Eq '^[^#]*zplug load' ${zshrc}; then
    print -P '%F{red}✗ You seem to have zplug enabled. Please disable it.%f' >&2
  else
    print -P '%F{green}✓%f No other Zsh frameworks detected.'
  fi
fi

# Clone Zim repo
print -n "Installing Zim in ${zim_home_str} …"
local err
if err=$(command git clone -b develop -q https://github.com/zimfw/zimfw.git ${ZIM_HOME} 2>&1); then
  print -P "\033[2K\r%F{green}✓%f Installed Zim in ${zim_home_str}"
else
  print -P "\033[2K\r%F{red}✗ Error installing Zim in ${zim_home_str}%f\n${err}" >&2
  return 1
fi

# Prepend templates
local template_file user_file user_file_str
for template_file in ${ZIM_HOME}/templates/*; do
  if [[ ${zim_home_str} != ${home_str}/.zim ]]; then
    command sed "s?${home_str}/.zim?${zim_home_str}?g" ${template_file} > ${template_file}.tmp
  else
    command cp ${template_file} ${template_file}.tmp
  fi
  user_file=${(e)home_str}/.${template_file:t}
  if [[ -e ${user_file} ]]; then
    user_file=${user_file:A}
    user_file_str=$(_replace_prefix ${home_str} ${user_file})
    if err=$(command cat ${template_file}.tmp ${user_file} > ${user_file}.tmp && \
        command mv ${user_file}{.tmp,} && command rm ${template_file}.tmp 2>&1); then
      print -P "%F{green}✓%f Prepended Zim template to ${user_file_str}"
    else
      print -P "%F{red}✗ Error prepending Zim template to ${user_file_str}%f\n${err}" >&2
    fi
  else
    user_file_str=$(_replace_prefix ${home_str} ${user_file})
    if err=$(command mv ${template_file}.tmp ${user_file} 2>&1); then
      print -P "%F{green}✓%f Copied Zim template to ${user_file_str}"
    else
      print -P "%F{red}✗ Error copying Zim template to ${user_file_str}%f\n${err}" >&2
    fi
  fi
done

print -n "Installing modules …"
# Will complain that modules are not installed at first, so silence that.
source ${ZIM_HOME}/init.zsh &>/dev/null
if err=$(zimfw install -q 2>&1); then
  print -P "\033[2K\r%F{green}✓%f Installed modules."
else
  print -P "\033[2K\r${err}\n%F{red}✗ Could not install modules.%f" >&2
fi

print -n "Compiling Zsh scripts …"
if err=$(zimfw compile -q 2>&1); then
  print -P "\033[2K\r%F{green}✓%f Compiled Zsh scripts."
else
  print -P "\033[2K\r%F{red}✗ Error compiling Zsh scripts.%f\n${err}" >&2
fi
} always {
  unfunction _replace_prefix
}
