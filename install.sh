#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
dotfilesDir=".dotfiles"

usage(){
  echo "Usage: ./install.sh [OPTION]"
  echo "Install, Uninstall or Restore dotfiles config."
  echo -e "\nThe action by default is going to be install"
  echo -e "\nArguments"
  echo -e "\n\t-h, --help\t print this information"
  echo -e "\t-u, --uninstall\t uninstall dotfiles"
  echo -e "\t-r, --restore\t restore original dotfiles config"
  echo -e "\nceso dotfiles config <https://github.com/ceso/dotfiles>"
  echo -e "\nMail: <leandro.lemos.2.4@gmail.com>"
}

uninstallDotfiles() {
  for file in $( ls "$HOME/$dotfilesDir" | grep '^_.*' | cut -d '_' -f2 ); do     

    dotfile="$HOME/$file"     

    if [[ -e "$dotfile.bkp" ]] && [[ -L "$dotfile" ]]; then
      unlink "$dotfile"
      mv "$HOME/$dotfilesDir/$file{.bkp,}"
    elif [[ -L "$HOME/$file" ]]; then
      unlink "$dotfile"        
    else
      echo -e "${GREEN}The dotfiles are already uninstalled, if you wish install them, please run ./install.sh -i${NC}"     
    fi

  done   

  rm -rf "$HOME/$dotfilesDir"
   
  if [[ "${?}" -eq 0 ]]; then
    echo -e "${GREEN}Success, dotfiles was uninstalled and original dotfiles was restored.${NC}"
  fi

}

createLink(){
  source="$PWD/$1"
  target="$HOME/${1/_/.}"

  if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
    mv "$target"{,.bkp}
  fi

  if [[ -n $( echo "$source" | grep '_terminator' ) ]]; then
    ln -sf "$source" "$HOME/.config/terminator/config"
  elif [[ -n $( echo "$source" | grep '_i3' ) ]]; then
    ln -sf "$source" "$HOME/.config/i3/config"
  else
    ln -sf "$source" "$target"
  fi

}   

checkDotfiles(){
  local count=0     

  if [[ -e "$HOME/$dotfilesDir" ]]; then
              
    for file in $( ls "$HOME/$dotfilesDir" | grep '^_.*' ); do     
      file=$( echo "${file}" | cut -d '_' -f2 )  

      if [[ -L "${HOME}/.${file}" ]]; then
        count=$(( count += 1 ))
      else
        count=$(( count -= 10 ))   
      fi   
                             
    done   

  else   
    local count=0       
  fi

  local myresult=${count}
  echo ${myresult}
}   

installDotfiles(){
  osFamily=$( grep 'ID_LIKE' /etc/os-release | cut -d '=' -f2 )
  packages="zsh vim git"
  gitRepository="https://github.com/ceso/dotfiles"

  if [[ "${osFamily}" = "debian" ]]; then
    sudo apt-get install -y -qq ${packages} 2> /dev/null
  else
    sudo yum install -y -q ${packages} 2> /dev/null    
  fi   

  result=$(checkDotfiles)

  if [[ ${result} -eq 0 ]]; then
    git clone "${gitRepository}" "${HOME}/${dotfilesDir}"        
    cd "${HOME}/${dotfilesDir}"
    git submodule update --init --recursive 

    for f in _* ; do
      createLink "${f}"        
    done  

    ${dotfilesDir}/powerline-fonts/install.sh
    sudo chsh -s $(which zsh)
    echo -e "${YELLOW}Please press enter for start with vim plugins installation${NC}"
    vim +PluginInstall +qall 2> /dev/null
    echo -e "\n${GREEN}Dotfiles installation finished :D"
    echo -e "\nhttps://github.com/ceso/dotfiles${NC}"
  elif [[ ${result} -gt 0 ]]; then
    echo -e "${RED}The ${HOME}/.dotfiles already exists, installation aborted${NC}" && exit         
  else
    echo -e "${RED}The ${HOME}/.dotfiles maybe exists, but the installation is wrong, please execute ./install.sh --uninstall and after ./install.sh --install${NC}" && exit 
  fi   
       
}

if [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]; then
   usage         
elif [[ "${1}" = "-u" ]] || [[ "${1}" = "--uninstall" ]]; then
   uninstallDotfiles
else    
   installDotfiles        
fi  
