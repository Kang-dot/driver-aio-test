#!/bin/bash

ARG=$@
SHELL_DIR="$( cd "$( dirname "$0" )" && pwd -P )"
DRIVER_NAME=""
VERSION_FILE=""
GIT_FILE=$(which git)
DRIVER_NAME_SET=false 
PHP_742=/usr/local/cubrid/php/php742
PHP_718=/usr/local/cubrid/php/php718
PHP_5631=/usr/local/cubrid/php/php5631
PHP_PATH=""
TEST_MODULE=""
TEST1_PATH=""
TEST2_PATH=""
IS_RELEASE=false

function show_usage ()
{
  echo "Usage: $0 -d Driver-Name -v Module-Version"
  echo "Note. For PDO Driver Release"
  echo ""
  echo " OPTIONS"
  echo "  -d Module-Name (cubrid-pdo or cubrid-php) [required]"
  echo "  -v Version (74 or 71 or 56) [required]"
  echo "  -r Remove source directory"
  echo "  -i Commit-ID"
  echo "  -h Show this help message and exit"
  echo ""
  echo " Commit-ID"
  echo " Command) git resete --hard [Commit-ID]"
  echo "          git submodule update"
  echo ""
  echo " EXAMPLES"
  echo "  $0 -m cubrid-pdo                                              # Compress "
  echo "  $0 -m cubrid-pdo -i a6ae44b76dc283bd74c555fef1585ed0ec7dc470  # Git Reset, Submodule Update and Compress"
  echo ""
}

function source_download ()
{
if [ ! -z "$SOURCE_DIR" ] && [ "$SOURCE_DIR" != "$SHELL_DIR" ] && [ "$REMOVE_SOURCE" != true ]; then
    echo "Removing existing SOURCE_DIR: $SOURCE_DIR"
    rm -rf "$SOURCE_DIR"
fi

if [ "$IS_RELEASE" = true ]; then
  git clone git@github.com:CUBRID/$DRIVER_NAME.git --recursive ${DRIVER_NAME}
else
  if [ "$DRIVER_NAME" = "cubrid-pdo" ]; then
    #git clone git@github.com:CUBRID/$DRIVER_NAME.git --recursive ${DRIVER_NAME}-${MODULE_VERSION}
    git clone git@github.com:hwany7seo/$DRIVER_NAME.git -b 11_4_test --recursive ${DRIVER_NAME}-${MODULE_VERSION} 
  else
    git clone git@github.com:hwany7seo/$DRIVER_NAME.git -b 11_4_test2 --recursive ${DRIVER_NAME}-${MODULE_VERSION} 
  fi
fi

if [ ! -z $COMMIT_ID ]; then
  echo "[CHECK] input commit id : $COMMIT_ID"
  cd $SOURCE_DIR
  git reset --hard $COMMIT_ID
  git submodule update
  cd $SHELL_DIR
fi

if [ -f $VERSION_FILE ]; then
  echo "[CHECK] version file : $VERSION_FILE"
  END_LINE=$(cat $VERSION_FILE | tail -1)
  DRIVER_VERSION=$(echo $END_LINE | cut -c 29-39)
else
  echo "[ERROR] Version file not found: $VERSION_FILE"
  cd $SHELL_DIR
  exit 1
fi

echo "$DRIVER_NAME Driver Version is $DRIVER_VERSION"
}

function release ()
{
cd $SHELL_DIR
rm -rf $SOURCE_DIR/.git
rm -rf $SOURCE_DIR/cci-src/.git

DRIVER_NAME_UPPER=$(echo $DRIVER_NAME | tr '[:lower:]' '[:upper:]')
tar zcf ${DRIVER_NAME_UPPER}-$DRIVER_VERSION.tar.gz $DRIVER_NAME
cp -v ${DRIVER_NAME_UPPER}-$DRIVER_VERSION.tar.gz $SHELL_DIR
echo "Release $DRIVER_VERSION Completed"
}

function build_source() {
  PHP_PATH=$1

  source_download 

  if [ -z "$PHP_PATH" ]; then
      echo "[ERROR] PHP version argument is required"
      exit 1
  fi
  
  echo "Build Module Path : $PHP_PATH"
  echo "Build Module Version : $MODULE_VERSION"
  echo "Build Driver Name : $DRIVER_NAME"

  cd $SHELL_DIR/$DRIVER_NAME-$MODULE_VERSION
  $PHP_PATH/bin/phpize
  ./configure --with-php-config=$PHP_PATH/bin/php-config
  make
  
  PHP_INI="$PHP_PATH/lib/php.ini"
  echo "Updating PHP INI file: $PHP_INI"

  if [ "$DRIVER_NAME" = "cubrid-pdo" ]; then
    if [ -f "modules/pdo_cubrid.so" ]; then
      cp -v modules/pdo_cubrid.so $PHP_PATH/lib/php/extensions/
      sed -i '/^extension=cubrid.so/d' "$PHP_INI"
      sed -i '/^extension=pdo_cubrid.so/d' "$PHP_INI"
      echo "extension=pdo_cubrid.so" >> "$PHP_INI"
    else
      echo "[ERROR] pdo_cubrid.so not found in modules directory"
      exit 1
    fi
  else
    if [ -f "modules/cubrid.so" ]; then
      cp -v modules/cubrid.so $PHP_PATH/lib/php/extensions/
      sed -i '/^extension=pdo_cubrid.so/d' "$PHP_INI"
      sed -i '/^extension=cubrid.so/d' "$PHP_INI"
      echo "extension=cubrid.so" >> "$PHP_INI"
    else
      echo "[ERROR] cubrid.so not found in modules directory"
      exit 1
    fi
  fi

  echo "Current active PHP extensions in php.ini:"
  grep "^extension=" "$PHP_INI"

  if $PHP_PATH/bin/php -m | grep -qi "CUBRID"; then
    echo "Module successfully loaded"
  else
    echo "[ERROR] Module not loaded properly"
    exit 1
  fi
  echo "Build Module Completed"
}

function php_test_module ()
{
  echo "PHP_PATH = $PHP_PATH"
  if $PHP_PATH/bin/php -m | grep -qi "CUBRID"; then
    echo "Module successfully loaded"
  else
    echo "[ERROR] Module not loaded properly"
    exit 1
  fi

  export TEST_PHP_EXECUTABLE=$PHP_PATH/bin/php
  echo "PHP Test1 Module : $TEST1_PATH"
  cd $TEST1_PATH
  $PHP_PATH/bin/php run-tests.php *.phpt | tee $SHELL_DIR/test1_result_${DRIVER_NAME}_${MODULE_VERSION}.txt
  echo "PHP Test1 Module Completed"

  echo "PHP Test2 Module : $TEST2_PATH"
  cd $TEST2_PATH
  sh choseRunCases.sh $PHP_PATH/bin -R
  cp -v runall_test.log $SHELL_DIR/test2_result_${DRIVER_NAME}_${MODULE_VERSION}.txt
  echo "PHP Test2 Module Completed"
}

function pdo_test_module ()
{
  echo "PHP_PATH = $PHP_PATH"
  echo "PDO Check Module : $PHP_PATH"
  PHP_MODULES=$($PHP_PATH/bin/php -m | tr -d '[:space:]')
  if [[ "$PHP_MODULES" =~ "pdo_cubrid" ]] && [[ "$PHP_MODULES" =~ "pdo_sqlite" ]]; then
    echo "Required PDO modules (CUBRID, SQLite) successfully loaded"
  else
    echo "[ERROR] One or more required PDO modules (CUBRID, SQLite) not loaded properly"
    echo "Loaded PDO modules:"
    $PHP_PATH/bin/php -m | grep "pdo_"
    exit 1
  fi

  echo "PDO Test Module : $TEST1_PATH"
  cd $TEST1_PATH
  export TEST_PHP_EXECUTABLE=$PHP_PATH/bin/php
  $PHP_PATH/bin/php run-tests.php *.phpt | tee $SHELL_DIR/test_result_${DRIVER_NAME}_${MODULE_VERSION}.txt
  echo "PDO Test Module Completed"
}

function checking ()
{
while getopts "i:hrd:v:" opt; do
  case $opt in
    r ) REMOVE_SOURCE=false
        echo "set remove source";;
    d ) DRIVER_NAME=$OPTARG
        echo "DRIVER_NAME = $DRIVER_NAME"
        if [ "$DRIVER_NAME" = "cubrid-pdo" ]; then
          DRIVER_NAME_SET=true
          DRIVER_NAME="cubrid-pdo"
          VERSION_FILE=pdo_cubrid_version.h
          TEST_MODULE="pdo_cubrid.so"
        elif [ "$DRIVER_NAME" = "cubrid-php" ]; then
          DRIVER_NAME_SET=true
          DRIVER_NAME="cubrid-php"
          VERSION_FILE=php_cubrid_version.h
          TEST_MODULE="cubrid.so"
        else
          echo "please input DRIVER_NAME (e.g. cubrid-pdo or cubrid-php)"
          exit 1
        fi
        ;;
    v ) echo "module version = $OPTARG"
        MODULE_VERSION="$OPTARG";
        if [ "$OPTARG" != "74" ] && [ "$OPTARG" != "71" ] && [ "$OPTARG" != "56" ]; then
          echo "please input module version (e.g. 74 or 71 or 56)"
          exit 1
        fi
        ;;
    i ) echo "commit id = $OPTARG"
        COMMIT_ID="$OPTARG";;
    h ) show_usage; exit 1;;
    * ) echo "$opt is not the option";;
  esac
done

shift $((OPTIND-1))
if [ "$1" = "release" ]; then
    IS_RELEASE=true
    echo "Release mode enabled"
fi

if [ "$IS_RELEASE" = true ]; then
  SOURCE_DIR=$SHELL_DIR/${DRIVER_NAME}
else
  SOURCE_DIR=$SHELL_DIR/${DRIVER_NAME}-${MODULE_VERSION}
fi
VERSION_FILE=$SOURCE_DIR/$VERSION_FILE

if [ "$DRIVER_NAME_SET" = false ]; then
    echo "[ERROR] -d option is required. Please specify driver name (cubrid-pdo or cubrid-php)"
    show_usage
    exit 1
fi

if [ "$IS_RELEASE" != true ]; then
  if [ "x$MODULE_VERSION" = "x" ]; then
    echo "[ERROR] -v option is required. Please specify module version (742 or 718 or 5631)"
    show_usage
    exit 1
  fi
fi

if [ "x$GIT_FILE" = "x" ]; then
    echo "[ERROR] Git not found"
    exit 1
fi

}

checking "$@"
echo "IS_RELEASE = $IS_RELEASE"

if [ "$IS_RELEASE" = true ]; then
    SOURCE_DIR=$SHELL_DIR/${DRIVER_NAME}
    source_download
    release
elif [ "$MODULE_VERSION" = "74" ]; then
    build_source $PHP_742
    TEST1_PATH=$SOURCE_DIR/tests_74
    if [ "$DRIVER_NAME" = "cubrid-pdo" ]; then
        echo "PDO Test Module : $TEST1_PATH"
        pdo_test_module
    else
        TEST2_PATH=$SOURCE_DIR/tests2_74
        php_test_module
    fi
elif [ "$MODULE_VERSION" = "71" ]; then
    build_source $PHP_718
    TEST1_PATH=$SOURCE_DIR/tests_7
    if [ "$DRIVER_NAME" = "cubrid-pdo" ]; then
        echo "PDO Test Module : $TEST1_PATH"
        pdo_test_module
    else
        TEST2_PATH=$SOURCE_DIR/tests2_7
        php_test_module
    fi
elif [ "$MODULE_VERSION" = "56" ]; then
    echo "PHP_PATH = $PHP_5631"
    build_source $PHP_5631
    TEST1_PATH=$SOURCE_DIR/tests
    if [ "$DRIVER_NAME" = "cubrid-pdo" ]; then
        echo "PDO Test Module : $TEST1_PATH"
        pdo_test_module
    else
        TEST2_PATH=$SOURCE_DIR/tests2
        php_test_module
    fi
else
    echo "[ERROR] Invalid module version"
    exit 1
fi
