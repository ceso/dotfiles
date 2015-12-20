#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

#uninstallDotfiles() {


createLink() {
   source="${PWD}/${1}"
   target="${HOME}/${1/_/.}"

   if [ -e "${target}" ] && [ ! -L "${target}" ]; then
      mv $target $target.ceso.bkp

   fi

   ln -sf ${source} ${target}

}   

checkDotfiles() {
   count=0     

   if [ -e "${HOME}/.dotfiles" ]; then
              
      for file in $( ls ${HOME}/.dotfiles | grep '^_.*' ); do     
         file=$( echo "${file}" | cut -d '_' -f2 )  

         if [ -L "${HOME}/.${file}" ]; then
            count=$(( count += 1 ))
         else
            count=$(( count -= 10 ))   
         fi   
                             
      done   

   else   
      count=0       
   fi

   local myresult=${count}
   echo ${myresult}
}   

installDotfiles() {
   getOS=$( grep -o '\(Debian\|Centos\|Fedora\|Red Hat\)' /etc/os-release | uniq )
   packages="zsh vim git"
   gitRepository="https://github.com/ceso/dotfiles"
   dotfilesDirectory="${HOME}/.dotfiles"

   if [ "${getOS}" = "Debian" ]; then
      sudo apt-get install -y -qq ${packages} 2> /dev/null
   else
      sudo yum install -y -q ${packages} 2> /dev/null    
   fi   

   result=$(checkDotfiles)

   if [[ ${result} -eq 0 ]]; then
      git clone "${gitRepository}" "${dotfilesDirectory}"        
      cd "${dotfilesDirectory}"
      git submodule update --init --recursive 

      for f in _* ; do
         createLink "${f}"        
      done  

      ${dotfilesDirectory}/powerline-fonts/install.sh

      sudo chsh -s $(which zsh)

      echo -e "${YELLOW}Please press enter for start with vim plugins installation${NC}"
      vim +PluginInstall +qall 2> /dev/null

      echo -e "\n${GREEN}Well, finally we finished the dotfiles installation :D"
      echo -e "I hope you like my dotfiles, but remember, please feel free of make your own changes, regards!!"
      echo -e "\nhttps://github.com/ceso/dotfiles${NC}"

   elif [[ ${result} -gt 0 ]]; then
      echo -e "${RED}The ${HOME}/.dotfiles already exists, installation aborted${NC}" && exit         
   else
      echo -e "${RED}The ${HOME}/.dotfiles maybe exists, but the installation is wrong, please execute ./install.sh --uninstall and after ./install.sh --install${NC}" && exit 
   fi   
       
}

if [ "${1}" = "-i" ] || [ "${1}" = "--install" ]; then
   installDotfiles
elif [ "${1}" = "-u" ] || [ "${1}" = "--uninstall" ]; then
   echo "uninstallDotfiles"
elif [ "${1}" = "-r" ] || [ "${1}" == "--restore" ]; then
    echo "restoreDotfiles    "
else    
  echo "usage"
fi  