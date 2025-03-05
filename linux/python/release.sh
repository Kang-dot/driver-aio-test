#!/bin/bash

ARG=$@
SHELL_DIR="$( cd "$( dirname "$0" )" && pwd -P )"
MODULE_NAME=cubrid-python
SOURCE_DIR=$SHELL_DIR/$MODULE_NAME
GIT_FILE=$(which git)
GIT_SOURCE=git@github.com:CUBRID/cubrid-python.git
VERSION_FILE=$SOURCE_DIR/VERSION
REMOVE_SOURCE=true
COMMIT_ID=

function show_usage ()
{
  echo "Usage: $0 [OPTIONS or Commit-ID]"
  echo "Note. For ${MODULE_NAME} Driver Release"
  echo ""
  echo " OPTIONS"
  echo "  -h Show this help message and exit"
  echo "  -i     Module Commit id"
  echo ""
  echo " Commit-ID"
  echo " Command) git resete --hard [Commit-ID]"
  echo "          git submodule update"
  echo ""
  echo " EXAMPLES"
  echo "  $0                                           # Compress "
  echo "  $0 a6ae44b76dc283bd74c555fef1585ed0ec7dc470  # Git Reset, Submodule Update and Compress"
  echo ""
}

function get_source() {
  echo "Get Source Function"
  if [ "x$GIT_FILE" = "x" ]; then
    echo "[ERROR] Git not found"
    exit 0
  fi
  
  echo "remove source ${REMOVE_SOURCE}"
  if [ "${REMOVE_SOURCE}" = true ]; then 
    if [ "x$SOURCE_DIR" != "x" ]; then
      echo "Deleted Source"
      rm -rf $SHELL_DIR/$MODULE_NAME
    fi
    echo "Source Git Clone"
    git clone $GIT_SOURCE
  elif [ ! -d $SOURCE_DIR ]; then
    echo "Source is not exist"
    git clone $GIT_SOURCE
  fi

  cd $SOURCE_DIR

  if [ "x$COMMIT_ID" != "x" ]; then
    echo "[CHECK] input commit id : $COMMIT_ID"
    git reset --hard $COMMIT_ID
    git submodule init
    git submodule update
  else
    if [ -d $SOURCE_DIR/cci-src ]; then
      rm -rf $SOURCE_DIR/cci-src
      echo "Get cubrid-cci"
      git clone git@github.com:CUBRID/cubrid-cci.git cci-src
    fi
  fi


  if [ -f $VERSION_FILE ]; then
    echo "[CHECK] version file : $VERSION_FILE"
    VERSION=$(cat $VERSION_FILE | tail -1)
  fi

  echo "$MODULE_NAME Driver Version is $VERSION"
}

echo "SOURCE DIR $SOURCE_DIR"
while getopts ":i:h" opt; do
  case $opt in
    i ) echo "commit id = $OPTARG"
        COMMIT_ID="$OPTARG";;
    h ) show_usage; exit 1;;
    * ) echo "$opt is not the option";;
  esac
done

if [ "x$GIT_FILE" = "x" ]; then
    echo "[ERROR] Git not found"
    exit 0
fi

get_source
$SOURCE_DIR/release.sh
cp -f $SOURCE_DIR/$MODULE_NAME*.tar.gz $SHELL_DIR
