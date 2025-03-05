#!/bin/bash
SHELL_DIR="$( cd "$( dirname "$0" )" && pwd -P )"

if [ $1 == "all" ]; then
    echo "all release"
    ${SHELL_DIR}/run.sh -d cubrid-pdo release
    ${SHELL_DIR}/run.sh -d cubrid-php release   
elif [ $1 == "pdo" ]; then
    echo "pdo release"
    ${SHELL_DIR}/run.sh -d cubrid-pdo release
elif [ $1 == "php" ]; then
    echo "php release"
    ${SHELL_DIR}/run.sh -d cubrid-php release
else
    echo "invalid argument pdo or php e.g. ./release.sh pdo"
fi
