## TODO: Fix detect os

#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
dotfilesDirectory="${HOME}/.dotfiles"

usage() {
echo "Usage: ./install.sh [OPTION]"
echo "Install, Uninstall or Restore dotfiles config."
echo -e "\nArguments"
echo -e "\n\t-h, --help\t print this information"
echo -e "\t-i, --install\t generate backup of actual dotfiles and after install ceso dotfiles"
echo -e "\t-u, --uninstall\t uninstall dotfiles"
echo -e "\t-r, --restore\t restore original dotfiles config"
echo -e "\nceso dotfiles config <https://github.com/ceso/dotfiles>"
echo -e "\nMail: <leandro.lemos.2.4@gmail.com>"
}

uninstallDotfiles() {
   for file in $( ls ${HOME}/.dotfiles | grep '^_.*' | cut -d '_' -f2 ); do     

      bkpDotfile="${HOME}/${file}"     
      linkDotfile="${HOME}/${file}"

      if [ -e "${bkpDotfile}.ceso.bkp" ] && [ -L "${linkDotfile}" ]; then
         unlink "${linkDotfile}"
         mv "${vkpDotfile}.ceso.bkp" "${HOME}/${file}"
      elif [ -L "${HOME}/${file}" ]; then
         unlink "${linkDotfile}"        
      else
         echo -e "${GREEN}The dotfiles are already uninstalled, if you wish install them, please run ./install.sh -i${NC}"     
      fi

   done   

   rm -rf "${dotfilesDirectory}"
   
   if [ "${?}" -eq 0 ]; then
      echo -e "${GREEN}Success, dotfiles was uninstalled and original dotfiles was restored.${NC}"
   fi

}

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
   uninstallDotfiles
else    
   usage
fi  
