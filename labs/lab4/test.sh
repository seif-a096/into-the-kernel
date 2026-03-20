#!/bin/bash
# Test script for fsearch
# Usage: place this script in the same directory as fsearch.c and run: bash test_fsearch.sh

PASS=0
FAIL=0
TOTAL=0

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================================
# Compile
# ============================================================
echo -e "${YELLOW}Compiling fsearch.c...${NC}"
gcc fsearch.c -o fsearch
if [ $? -ne 0 ]; then
    echo -e "${RED}Compilation FAILED!${NC}"
    exit 1
fi
echo -e "${GREEN}Compilation OK${NC}"
echo ""

# ============================================================
# Create test files with exact byte sizes using truncate
# f1=100, f2=200, f3=300, f4=400, f5=500, f6=600, f7=700
# ============================================================
truncate -s 100 f1.txt
truncate -s 200 f2.txt
truncate -s 300 f3.txt
truncate -s 400 f4.txt
truncate -s 500 f5.txt
truncate -s 600 f6.txt
truncate -s 700 f7.txt

# ============================================================
# Helper: run one test
# ============================================================
run_test() {
    local test_name="$1"
    local expected="$2"
    shift 2
    local cmd=("$@")

    TOTAL=$((TOTAL + 1))

    actual=$(${cmd[@]} 2>/dev/null)
    ret=$?

    # Normalize: trim trailing whitespace, strip trailing period, then sort lines
    normalize() {
        echo "$1" | sed 's/[[:space:]]*$//' | sed 's/\.$//' | sort
    }

    actual_sorted=$(normalize "$actual")
    expected_sorted=$(normalize "$expected")

    if [ "$actual_sorted" = "$expected_sorted" ]; then
        echo -e "  ${GREEN}PASS${NC} - $test_name"
        echo    "         Output: $(echo "$actual" | tr '\n' '|')"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} - $test_name"
        echo    "         Expected: $(echo "$expected" | tr '\n' '|')"
        echo    "         Got:      $(echo "$actual"   | tr '\n' '|')"
        FAIL=$((FAIL + 1))
    fi
}

# ============================================================
# TESTS
# ============================================================

echo "========================================"
echo " TEST RESULTS"
echo "========================================"
echo ""

# ------------------------------------------------------------
echo -e "${CYAN}--- Winner: Child A ---${NC}"
# ------------------------------------------------------------

# Child A searches indices 0-1, Child B searches 2-3
# f1(100) is at index 0 → Child A wins
run_test "Child A wins (index 0, even files)" \
"I found the file at location 0.
Parent: Child A found the file.
I am child B, and I received from my parent that I am the loser." \
./fsearch 100 f1.txt f2.txt f3.txt f4.txt

# Child A searches 0-1, f2(200) at index 1 → Child A wins
run_test "Child A wins (index 1, even files)" \
"I found the file at location 1.
Parent: Child A found the file.
I am child B, and I received from my parent that I am the loser." \
./fsearch 200 f1.txt f2.txt f3.txt f4.txt

# Odd files (5): Child A gets 3 (0-2), Child B gets 2 (3-4)
# f1(100) at index 0 → Child A wins
run_test "Child A wins (index 0, odd files)" \
"I found the file at location 0.
Parent: Child A found the file.
I am child B, and I received from my parent that I am the loser." \
./fsearch 100 f1.txt f2.txt f3.txt f4.txt f5.txt

# Odd files (5): Child A gets 3 (0-2), f3(300) at index 2 → Child A wins
run_test "Child A wins (index 2, odd files - last of A's range)" \
"I found the file at location 2.
Parent: Child A found the file.
I am child B, and I received from my parent that I am the loser." \
./fsearch 300 f1.txt f2.txt f3.txt f4.txt f5.txt

# Single file → Child A gets it, Child B gets nothing
run_test "Child A wins (single file)" \
"I found the file at location 0.
Parent: Child A found the file.
I am child B, and I received from my parent that I am the loser." \
./fsearch 100 f1.txt

# 2 files: Child A gets index 0, Child B gets index 1
# f1(100) at index 0 → Child A wins
run_test "Child A wins (2 files)" \
"I found the file at location 0.
Parent: Child A found the file.
I am child B, and I received from my parent that I am the loser." \
./fsearch 100 f1.txt f2.txt

# ------------------------------------------------------------
echo ""
echo -e "${CYAN}--- Winner: Child B ---${NC}"
# ------------------------------------------------------------

# Even files (4): Child A gets 0-1, Child B gets 2-3
# f3(300) at index 2 → Child B wins
run_test "Child B wins (index 2, even files)" \
"I found the file at location 2.
Parent: Child B found the file.
I am child A, and I received from my parent that I am the loser." \
./fsearch 300 f1.txt f2.txt f3.txt f4.txt

# f4(400) at index 3 → Child B wins (matches assignment example)
run_test "Child B wins (index 3, assignment example)" \
"I found the file at location 3.
Parent: Child B found the file.
I am child A, and I received from my parent that I am the loser." \
./fsearch 400 f1.txt f2.txt f3.txt f4.txt

# Odd files (5): Child A gets 0-2, Child B gets 3-4
# f4(400) at index 3 → Child B wins
run_test "Child B wins (index 3, odd files)" \
"I found the file at location 3.
Parent: Child B found the file.
I am child A, and I received from my parent that I am the loser." \
./fsearch 400 f1.txt f2.txt f3.txt f4.txt f5.txt

# f5(500) at index 4 → Child B wins
run_test "Child B wins (index 4, odd files - last of B's range)" \
"I found the file at location 4.
Parent: Child B found the file.
I am child A, and I received from my parent that I am the loser." \
./fsearch 500 f1.txt f2.txt f3.txt f4.txt f5.txt

# 2 files: Child A=index0, Child B=index1, f2(200) → Child B wins
run_test "Child B wins (2 files)" \
"I found the file at location 1.
Parent: Child B found the file.
I am child A, and I received from my parent that I am the loser." \
./fsearch 200 f1.txt f2.txt

# 6 files: A gets 0-2, B gets 3-5, f6(600) at index 5 → Child B wins
run_test "Child B wins (index 5, 6 files)" \
"I found the file at location 5.
Parent: Child B found the file.
I am child A, and I received from my parent that I am the loser." \
./fsearch 600 f1.txt f2.txt f3.txt f4.txt f5.txt f6.txt

# ------------------------------------------------------------
echo ""
echo -e "${CYAN}--- Not Found (5s timeout) ---${NC}"
# ------------------------------------------------------------

# Size 999 doesn't exist in any file
run_test "Not found (2 files)" \
"I am the child and I could not find the file.
I am the child and I could not find the file." \
./fsearch 999 f1.txt f2.txt

run_test "Not found (4 files)" \
"I am the child and I could not find the file.
I am the child and I could not find the file." \
./fsearch 999 f1.txt f2.txt f3.txt f4.txt

run_test "Not found (single file)" \
"I am the child and I could not find the file.
I am the child and I could not find the file." \
./fsearch 999 f1.txt

run_test "Not found (odd files)" \
"I am the child and I could not find the file.
I am the child and I could not find the file." \
./fsearch 999 f1.txt f2.txt f3.txt f4.txt f5.txt

# ------------------------------------------------------------
echo ""
echo -e "${CYAN}--- Boundary / Edge Cases ---${NC}"
# ------------------------------------------------------------

# 7 files (odd): A gets 0-3, B gets 4-6
# f4(400) at index 3 → Child A wins (last of A's range)
run_test "Child A wins (last index of A range, 7 files)" \
"I found the file at location 3.
Parent: Child A found the file.
I am child B, and I received from my parent that I am the loser." \
./fsearch 400 f1.txt f2.txt f3.txt f4.txt f5.txt f6.txt f7.txt

# f5(500) at index 4 → Child B wins (first of B's range)
run_test "Child B wins (first index of B range, 7 files)" \
"I found the file at location 4.
Parent: Child B found the file.
I am child A, and I received from my parent that I am the loser." \
./fsearch 500 f1.txt f2.txt f3.txt f4.txt f5.txt f6.txt f7.txt

# f7(700) at index 6 → Child B wins (last file)
run_test "Child B wins (last file, index 6)" \
"I found the file at location 6.
Parent: Child B found the file.
I am child A, and I received from my parent that I am the loser." \
./fsearch 700 f1.txt f2.txt f3.txt f4.txt f5.txt f6.txt f7.txt

# ============================================================
# Cleanup
# ============================================================
rm -f f1.txt f2.txt f3.txt f4.txt f5.txt f6.txt f7.txt fsearch

# ============================================================
# Summary
# ============================================================
echo ""
echo "========================================"
if [ $FAIL -eq 0 ]; then
    echo -e " ${GREEN}ALL $TOTAL TESTS PASSED!${NC} ✓"
else
    echo -e " ${RED}$FAIL/$TOTAL TESTS FAILED${NC}"
    echo -e " ${GREEN}$PASS/$TOTAL TESTS PASSED${NC}"
fi
echo "========================================"