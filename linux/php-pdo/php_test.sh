#!/bin/bash

SHELL_DIR=$(dirname $(readlink -f $0))
CURRENT_DIR=$(pwd)

function run_php_test() {
    local version=$1
    echo "=== Running PHP test for PHP $version ==="
    ./run.sh -d cubrid-php -v $version
}

function show_results() {
    echo -e "\n=== Test Results ==="
    echo "Result files generated:"
    for result in $SHELL_DIR/*result*php*.txt; do
        if [ -f "$result" ]; then
            echo -e "\n- $(basename $result):"
            awk '
                /^={20,}/{
                    if (count == 0) {
                        p = 1;
                        count++;
                    } else if (count == 1) {
                        p = 0;
                        count++;
                    } else if (count == 2) {
                        p = 1;
                    }
                }
                p { print }
            ' "$result"
        fi
    done
}

function run_all_tests() {
    echo "Starting all PHP tests..."
    run_php_test "56"
    run_php_test "71"
    run_php_test "74"
}

# 명령행 인자 처리
if [ $# -eq 0 ]; then
    echo "Usage: $0 [version|all]"
    echo "  version: 56 | 71 | 74"
    echo "  all: Run tests for all PHP versions"
    exit 1
fi

case "$1" in
    "all")
        echo "run_all_tests"
        run_all_tests
        ;;
    "56"|"71"|"74")
        echo "run_php_test $1"
        run_php_test "$1"
        ;;
    *)
        echo "Error: Invalid version. Use 56, 71, 74 or all"
        echo "Usage: $0 [version|all]"
        echo "  version: 56 | 71 | 74"
        echo "  all: Run tests for all PHP versions"
        exit 1
        ;;
esac

# 결과 출력
show_results

