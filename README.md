# DBMS Driver Automation Test Project

This project aims to perform automated tests on various DBMS drivers and collect and integrate test results to provide them in a comparable format.

---

## Linux Tests

**Supported Drivers:**
- PHP
- PDO
- Python
- Node.js
- Perl
- Ruby

### How to Run Tests

#### PHP
```bash
cd linux/php-pdo
sh php_test.sh
```

#### PDO
```bash
cd linux/php-pdo
sh pdo_test.sh
```

#### Python
```bash
cd linux/python
sh test.sh
```

#### Node.js
```bash
cd linux/test
sh node_test.sh
```

#### Perl
```bash
cd linux/test
sh perl_test.sh
```

#### Ruby
```bash
cd linux/test
sh ruby_test.sh
```

### Test Results

Each test prints its results to the console. To aggregate and view all test results in a unified format, use the summary script below:

#### Result Integration Script

```bash
cd linux
sh summary_result.sh
```

---

## Windows Tests

**Supported Drivers:**
- ADO.NET
- ODBC
- PDO
- PHP
- Python

### How to Run Tests

#### ADO.NET
```bat
cd win\ado.net
adonet_test.bat
```

#### ODBC
```bat
cd win\odbc
odbc_test.bat
```

#### PDO
```bat
cd win\pdo
envsetup.bat pdo-5.6.31 pdo
envsetup.bat pdo-7.1.8 pdo
envsetup.bat pdo-7.4.2 pdo
all_test.bat pdo-5.6.31
all_test.bat pdo-7.1.8
all_test.bat pdo-7.4.2
```

#### PHP
```bat
cd win\pdo
envsetup.bat php-5.6.31 php
envsetup.bat php-7.1.8 php
envsetup.bat php-7.4.2 php
all_test.bat php-5.6.31
all_test.bat php-7.1.8
all_test.bat php-7.4.2
```

#### Python
```bat
cd win\python
test.bat
```

### Test Results

Each test prints its results to the console. To aggregate and view all test results in a unified format, use the summary script below:

#### Result Integration Script

```powershell
cd win\
summary_result.ps1
```

