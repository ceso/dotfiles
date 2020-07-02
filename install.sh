#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
DOTFILES_DIR=".dotfiles"

check_dotfiles(){
  local result=0

  if [[ -d "${HOME}/${DOTFILES_DIR}" ]]; then
    
    for conf in $( ls "${HOME}/${DOTFILES_DIR}" | grep '^_.*' ); do
      conf=$( echo "${conf}" | cut -d '_' -f2 )

      if [[ -L "${HOME}/.${conf}" || -L "${HOME}/.config/${conf}" || -L "${HOME}/.config/Code/User/${config}" ]]; then
        result=$(( count +=1 ))
      else
        result=$(( count -= 10 ))
      fi

    done

  else
    local result=0
  fi 

  echo "${result}"
}      

create_link(){
  local source="$PWD/$1"
  local target="$HOME/${1/_/.}"

  if [[ ! -d "~/.config" ]]; then
    mkdir -p "${HOME}/.config/{terminator,i3,Code/User}"
  fi
   
  if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
    mv "$target"{,.bkp}
  fi


  if [[ -n $( echo "$source" | grep '_terminator' ) ]]; then
    ln -sf "$source" "${HOME}/.config/terminator/config"
  elif [[ -n $( echo "$source" | grep '_i3' ) ]]; then
    ln -sf "$source" "${HOME}/.config/i3/config"
  elif [[ -n $( echo "$source" | grep '_settings.json' ) ]]; then
    ln -sf "$source" "${HOME}/.config/Code/User/settings.json"
  else
    ln -sf "$source" "$target"
  fi

}   

install_dotfiles(){
  local git_repository="https://github.com/ceso/dotfiles"

  is_installed=$(check_dotfiles)

  if [[ ${is_installed} -eq 0 ]]; then
    git clone "${git_repository}" "${HOME}/${DOTFILES_DIR}"        
    cd "${HOME}/${DOTFILES_DIR}"
    git submodule update --init --recursive 

    for conf in _* ; do
      create_link "${conf}"        
    done  

    "${HOME}/${DOTFILES_DIR}/powerline-fonts/install.sh"
    sudo /usr/sbin/usermod -s "$(which zsh)" "$(whoami)"
    vim +PluginInstall +qall 2> /dev/null
  else
    echo -e "${RED}The ${HOME}/.dotfiles already exists, installation aborted${NC}" && exit         
  fi   
}

install_dotfiles
