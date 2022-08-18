#!/bin/bash
# ---------------Parameters------------------
# $1 : re-create password
# $2 : force delete mysql installation folder 
# $3 : build monitor

DOCKER_BUILDKIT=1
source ./.env

reCreatePassword() {
  local folderRoot="./Mysql/Passwords/$MYSQL_PW_ROOT_FILE"
  local folderUser="./Mysql/Passwords/$MYSQL_PW_FILE"
  
  openssl rand -base64 14 | awk '{print tolower($0)}' > "$folderRoot"
  openssl rand -base64 14 | awk '{print tolower($0)}' > "$folderUser"
  
  echo "Recreating password..."
}
init() {
  # ---------------Parameters------------------
  # $1 : re-create password
  # $2 : force delete mysql installation folder 
  # $3 : build monitor default: false

  local ReCreatePw=$1
  local ReCreateInstallation=$2
  local existPasswordFile=$([[ -f "./Mysql/Passwords/$MYSQL_PW_ROOT_FILE" &&
                          -f "./Mysql/Passwords/$MYSQL_PW_FILE"
                      ]] && echo t )

  docker-compose -f "docker-compose.yml" stop mysql

  # TODO : check if it is necessary to delete installation when creating the password
  
  if [[ ! $existPasswordFile || "$ReCreatePw" == "true" ]]
  then
    reCreatePassword
    docker-compose rm mysql
    rm -rf ./Mysql/Installation
    echo "Deleted Mysql installation and reseted password"

  elif [[ "$ReCreateInstallation" == "true" ]]
  then
    docker-compose rm mysql
    rm -rf ./Mysql/Installation
    echo "Deleted Mysql installation"

  fi

  mkdir -p ./VsCodeConfigFolders/Mysql
  mkdir -p ./VsCodeConfigFolders/Frontend
  mkdir -p ./VsCodeConfigFolders/Backend

  docker-compose -f docker-compose.yml up -d --build
  docker-compose -f docker-compose-db.yml up -d --build
  
  # sh backupDev.sh

  if [[ "$3" ]]
  then
    cd Monitor
    docker-compose -f docker-compose.yml up -d --build
  fi
}

if [[ "$1" && "$2" ]]
then
  if [[ "$3" ]]
  then
    init $1 $2 $3
  else
    init $1 $2
  fi
fi

# recommended in mysql dev
# sh reBuild.sh false true

# recommended in nodejs and reactjs dev
# sh reBuild.sh false false

# for first time
# sh reBuild.sh true true
