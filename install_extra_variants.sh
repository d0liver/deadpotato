#/usr/bin/env bash

red="\033[0;31m"
green="\033[0;32m"

if ! hash wget
then
  echo -e "${red}Wget is not installed." >&2
  exit 1
else
  echo -e "${green}Wget is installed." >&2
fi

if [ ! -d "./variants" ]
then
  echo -e "${green}Attempting to create variants directory..." >&2

  if ! mkdir "./variants"
  then
    echo -e "${red}Failed to create variants directory." >&2
    exit 1
  fi
fi

cd variants
wget 
