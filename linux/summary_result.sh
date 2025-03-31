RESULT_FILE="./total_result"

PERL_RESULT_FILE="./perl_test_result.result"
RUBY_RESULT_FILE="./ruby_test_result.result"
NODE_LOG_FILE="./node_test_result.result" 

# PYTHON_LOG_FILES=(
#     PYTHON_LOG_FILE_1="./linux/python/cubrid-python/tests2/tests2.result"
#     PYTHON_LOG_FILE_2="./linux/python/cubrid-python/tests/python2_result/test_cubrid.result"
#     PYTHON_LOG_FILE_3="./linux/python/cubrid-python/tests/python2_result/test_CUBRIDdb.result"
#     PYTHON_LOG_FILE_4="./linux/python/cubrid-python/tests/python3_result/test_cubrid.result"
#     PYTHON_LOG_FILE_5="./linux/python/cubrid-python/tests/python3_result/test_CUBRIDdb.result"
# )

PYTHON_LOG_FILES=(
    "./python/cubrid-python/tests2/tests2.result"
    "./python/cubrid-python/tests/python2_result/test_cubrid.result"
    "./python/cubrid-python/tests/python2_result/test_CUBRIDdb.result"
    "./python/cubrid-python/tests/python3_result/test_cubrid.result"
    "./python/cubrid-python/tests/python3_result/test_CUBRIDdb.result"
)

PHP_PDO_LOG_FILES=(
    "./php-pdo/test_result_cubrid-pdo_56.txt"
    "./php-pdo/test_result_cubrid-pdo_71.txt"
    "./php-pdo/test_result_cubrid-pdo_74.txt"
    "./php-pdo/test1_result_cubrid-php_56.txt"
    "./php-pdo/test1_result_cubrid-php_71.txt"
    "./php-pdo/test1_result_cubrid-php_74.txt"
    "./php-pdo/test2_result_cubrid-php_56.txt"
    "./php-pdo/test2_result_cubrid-php_71.txt"
    "./php-pdo/test2_result_cubrid-php_74.txt"
)

echo "=== Test Results ($(date '+%Y-%m-%d %H:%M:%S')) ===" > "$RESULT_FILE"

#perl
if grep -qi "Result: PASS" "$PERL_RESULT_FILE"; then
    echo "perl: pass" | tee -a "$RESULT_FILE"
else
    echo "perl: some case failed" | tee -a "$RESULT_FILE"
fi

# ruby
if grep -Eqi "(failures: [^0]|errors: [^0])" "$RUBY_RESULT_FILE"; then
    FAIL_COUNT=$(grep -i "failures:" "$RUBY_RESULT_FILE" | grep -o 'failures: [0-9]\+' | awk '{print $2}')
    ERROR_COUNT=$(grep -i "errors:" "$RUBY_RESULT_FILE" | grep -o 'errors: [0-9]\+' | awk '{print $2}')
    echo "ruby: fail (${FAIL_COUNT} failures, ${ERROR_COUNT} errors)" | tee -a "$RESULT_FILE"
    DETAILS=()
    [[ "$FAIL_COUNT" != "0" ]] && DETAILS+=("${FAIL_COUNT} failures")
    [[ "$ERROR_COUNT" != "0" ]] && DETAILS+=("${ERROR_COUNT} errors")

    DETAIL_TEXT=$(IFS=', '; echo "${DETAILS[*]}")
    echo "ruby: fail (${DETAIL_TEXT})" | tee -a "$RESULT_FILE"
elif grep -qi "passed" "$RUBY_RESULT_FILE"; then
    echo "ruby: pass" | tee -a "$RESULT_FILE"
else
    echo "ruby: unknown result" | tee -a "$RESULT_FILE"
fi

# node.js
if grep -qi "failing" "$NODE_LOG_FILE"; then
    FAIL_COUNT=$(grep -i "failing" "$NODE_LOG_FILE" | grep -o '[0-9]\+')
    echo "node: fail (${FAIL_COUNT} tests failed)" | tee -a "$RESULT_FILE"
else
    echo "node: pass" | tee -a "$RESULT_FILE"
fi

# python
PYTHON_FAIL_COUNT=0
PYTHON_FAIL_DETAILS=()

for FILE in "${PYTHON_LOG_FILES[@]}"; do
    COUNT=$(grep -i "Failed" "$FILE" | wc -l)
    if [ "$COUNT" -gt 0 ]; then
        PYTHON_FAIL_COUNT=$((PYTHON_FAIL_COUNT + COUNT))
        BASENAME=$(basename "$FILE")
        PYTHON_FAIL_DETAILS+=("${BASENAME}: ${COUNT} failed")
    fi
done

if [ "$PYTHON_FAIL_COUNT" -gt 0 ]; then
    DETAIL_TEXT=$(IFS=', '; echo "${PYTHON_FAIL_DETAILS[*]}")
    echo "python: fail (${PYTHON_FAIL_COUNT} test cases failed — $DETAIL_TEXT)" | tee -a "$RESULT_FILE"
else
    echo "python: pass" | tee -a "$RESULT_FILE"
fi

# --- PHP-PDO ---
PHP_PDO_FAIL_COUNT=0
PHP_PDO_FAIL_DETAILS=()

for FILE in "${PHP_PDO_LOG_FILES[@]}"; do
    FAILED_COUNT=$(grep -i "Tests failed" "$FILE" | grep -oE 'Tests failed[[:space:]]*:[[:space:]]*[0-9]+' | grep -oE '[0-9]+$')
    if [[ "$FAILED_COUNT" =~ ^[0-9]+$ ]]; then
        if [ "$FAILED_COUNT" -gt 0 ]; then
            PHP_PDO_FAIL_COUNT=$((PHP_PDO_FAIL_COUNT + FAILED_COUNT))
            BASENAME=$(basename "$FILE")
            PHP_PDO_FAIL_DETAILS+=("${BASENAME}: ${FAILED_COUNT} failed")
        fi
    fi
done

if [ "$PHP_PDO_FAIL_COUNT" -gt 0 ]; then
    DETAIL_TEXT=$(IFS=', '; echo "${PHP_PDO_FAIL_DETAILS[*]}")
    echo "php-pdo: fail (${PHP_PDO_FAIL_COUNT} tests failed — $DETAIL_TEXT)" | tee -a "$RESULT_FILE"
else
    echo "php-pdo: pass" | tee -a "$RESULT_FILE"
fi