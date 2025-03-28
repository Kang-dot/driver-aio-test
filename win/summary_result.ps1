$ResultFile = "./total_result.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"=== Test Results ($timestamp) ===" | Out-File -FilePath $ResultFile -Encoding UTF8

# --- ADO.NET ---
$AdoFiles = @(
    "./ado.net/ado_net_test.result"
    "./ado.net/ado_test_funtional_test.result"
)

$AdoFailCount = 0
$AdoDetails = @()

foreach ($file in $AdoFiles) {
    $content = Get-Content $file
    $failLine = $content | Select-String "총 테스트 수:"

    if ($failLine -match "실패:\s*(\d+)") {
        $count = [int]$matches[1]
        if ($count -gt 0) {
            $AdoFailCount += $count
            $AdoDetails += "$(Split-Path $file -Leaf): $count failed"
        }
    }
}

if ($AdoFailCount -gt 0) {
    $joined = $AdoDetails -join ", "
    "ado.net: fail ($AdoFailCount tests failed — $joined)" | Tee-Object -FilePath $ResultFile -Append
} else {
    "ado.net: pass" | Tee-Object -FilePath $ResultFile -Append
}

# --- ODBC ---
$OdbcFiles = @(
    "./odbc/unit_test.result",
    "./odbc/unit_test_cpp.result"
)

$OdbcFailCount = 0
$OdbcDetails = @()

foreach ($file in $OdbcFiles) {
    $content = Get-Content $file
    $failLine = $content | Select-String "총 테스트 수:"

    if ($failLine -match "실패:\s*(\d+)") {
        $count = [int]$matches[1]
        if ($count -gt 0) {
            $OdbcFailCount += $count
            $OdbcDetails += "$(Split-Path $file -Leaf): $count failed"
        }
    }
}

if ($OdbcFailCount -gt 0) {
    $joined = $OdbcDetails -join ", "
    "odbc: fail ($OdbcFailCount tests failed — $joined)" | Tee-Object -FilePath $ResultFile -Append
} else {
    "odbc: pass" | Tee-Object -FilePath $ResultFile -Append
}

# --- PHP ---
$PhpFiles = @(
    "./php/result/result_test1_php56_nts",
    "./php/result/result_test1_php56_ts",
    "./php/result/result_test1_php71_nts",
    "./php/result/result_test1_php71_ts",
    "./php/result/result_test2_php56_ts",
    "./php/result/result_test2_php71_nts",
    "./php/result/result_test2_php71_ts",
    "./php/result/result_test2_php74_nts",
    "./php/result/result_test2_php74_ts"
)

$PhpFailCount = 0
$PhpDetails = @()

foreach ($file in $PhpFiles) {
    $failedLine = Get-Content $file | Select-String "Tests failed"
    if ($failedLine -match "Tests failed\s*:\s*(\d+)") {
        $count = [int]$matches[1]
        if ($count -gt 0) {
            $PhpFailCount += $count
            $PhpDetails += "$(Split-Path $file -Leaf): $count failed"
        }
    }
}

if ($PhpFailCount -gt 0) {
    $joined = $PhpDetails -join ", "
    "php: fail ($PhpFailCount tests failed — $joined)" | Tee-Object -FilePath $ResultFile -Append
} else {
    "php: pass" | Tee-Object -FilePath $ResultFile -Append
}

# --- PHP-PDO ---
$PdoFiles = @(
    "./pdo/result/result_php56",
    "./pdo/result/result_php71",
    "./pdo/result/result_php74"
)

$PdoFailCount = 0
$PdoDetails = @()

foreach ($file in $PdoFiles) {
    $failedLine = Get-Content $file | Select-String "Tests failed"
    if ($failedLine -match "Tests failed\s*:\s*(\d+)") {
        $count = [int]$matches[1]
        if ($count -gt 0) {
            $PdoFailCount += $count
            $PdoDetails += "$(Split-Path $file -Leaf): $count failed"
        }
    }
}

if ($PdoFailCount -gt 0) {
    $joined = $PdoDetails -join ", "
    "pdo: fail ($PdoFailCount tests failed — $joined)" | Tee-Object -FilePath $ResultFile -Append
} else {
    "pdo: pass" | Tee-Object -FilePath $ResultFile -Append
}

# --- Python ---
$PythonFiles = @(
    "./python/result/0/test_cubrid.result",
    "./python/result/0/test_CUBRIDdb.result",
    "./python/result/1/test_cubrid.result",
    "./python/result/1/test_CUBRIDdb.result"
)

$PythonFailCount = 0
$PythonDetails = @()

foreach ($file in $PythonFiles) {
    $count = (Select-String -Path $file -Pattern "Failed" -SimpleMatch).Count
    if ($count -gt 0) {
        $PythonFailCount += $count
        $PythonDetails += "$(Split-Path $file -Leaf): $count failed"
    }
}

if ($PythonFailCount -gt 0) {
    $joined = $PythonDetails -join ", "
    "python: fail ($PythonFailCount test cases failed — $joined)" | Tee-Object -FilePath $ResultFile -Append
} else {
    "python: pass" | Tee-Object -FilePath $ResultFile -Append
}
