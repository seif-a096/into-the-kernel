#!/bin/bash
# Test script for assignment3.c
# Usage: bash test_assignment3.sh

PASS=0
FAIL=0
TOTAL=0

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compile
echo -e "${YELLOW}Compiling assignment3.c...${NC}"
gcc assignment3.c -o assignment3.o
if [ $? -ne 0 ]; then
    echo -e "${RED}Compilation FAILED!${NC}"
    exit 1
fi
echo -e "${GREEN}Compilation OK${NC}"
echo ""

# Helper function to run a test
run_test() {
    local test_name="$1"
    local input_file="$2"
    local n_disp="$3"
    local v_min="$4"
    local expected="$5"

    TOTAL=$((TOTAL + 1))

    # Run program and capture output + return code
    actual=$(./assignment3.o "$input_file" "$n_disp" "$v_min")
    ret_code=$?

    # Trim whitespace (handles \b and trailing spaces)
    actual=$(echo "$actual" | sed 's/[[:space:]]*$//' | tr -d '\b')
    expected_trimmed=$(echo "$expected" | sed 's/[[:space:]]*$//')

    if [ "$actual" = "$expected_trimmed" ] && [ "$ret_code" -eq 0 ]; then
        echo -e "  ${GREEN}PASS${NC} - $test_name"
        echo "         Output: '$actual'"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} - $test_name"
        if [ "$actual" != "$expected_trimmed" ]; then
            echo "         Expected: '$expected_trimmed'"
            echo "         Got:      '$actual'"
        fi
        if [ "$ret_code" -ne 0 ]; then
            echo "         Return code: $ret_code (expected 0)"
        fi
        FAIL=$((FAIL + 1))
    fi
}

# ============================================================
# Create test input files
# ============================================================

# Test 1: Assignment example (9 orders, 3 dispatchers, V=50)
cat > _test_01.txt << EOF
9
3 10
5 20
2 30
4 5
6 8
1 70
3 15
2 40
7 6
EOF

# Test 2: All orders eligible (every order >= V)
cat > _test_02.txt << EOF
4
10 10
5 20
3 40
2 60
EOF

# Test 3: No orders eligible (every order < V)
cat > _test_03.txt << EOF
4
1 5
2 3
1 2
3 1
EOF

# Test 4: Single order, single dispatcher
cat > _test_04.txt << EOF
1
5 20
EOF

# Test 5: Remainder case (5 orders, 2 dispatchers = 2+3)
cat > _test_05.txt << EOF
5
10 10
1 1
1 1
1 1
8 20
EOF

# Test 6: Remainder case (7 orders, 3 dispatchers = 2+2+3)
cat > _test_06.txt << EOF
7
3 20
5 10
2 5
1 100
4 30
6 15
10 10
EOF

# Test 7: Many dispatchers, 1 order each (4 orders, 4 dispatchers)
cat > _test_07.txt << EOF
4
10 10
1 1
5 20
2 3
EOF

# Test 8: Large V, only some qualify
cat > _test_08.txt << EOF
6
100 100
1 1
50 50
2 2
200 200
3 3
EOF

# Test 9: All same orders
cat > _test_09.txt << EOF
6
5 10
5 10
5 10
5 10
5 10
5 10
EOF

# Test 10: Single dispatcher (all orders go to one)
cat > _test_10.txt << EOF
5
3 10
5 20
2 30
4 5
1 70
EOF

# ============================================================
# Run tests
# ============================================================

echo "========================================"
echo " TEST RESULTS"
echo "========================================"
echo ""

echo "--- Assignment Example ---"
# Batch 1: orders 0-2 → 3*10=30, 5*20=100✓, 2*30=60✓ → 2
# Batch 2: orders 3-5 → 4*5=20, 6*8=48, 1*70=70✓ → 1
# Batch 3: orders 6-8 → 3*15=45, 2*40=80✓, 7*6=42 → 1
run_test "9 orders, 3 dispatchers, V=50" "_test_01.txt" 3 50 "2 1 1"

echo ""
echo "--- All Eligible / None Eligible ---"
# 4 orders, 2 dispatchers, V=50
# Batch 1: 10*10=100✓, 5*20=100✓ → 2
# Batch 2: 3*40=120✓, 2*60=120✓ → 2
run_test "All eligible, V=50" "_test_02.txt" 2 50 "2 2"

# 4 orders, 2 dispatchers, V=100
# Batch 1: 1*5=5, 2*3=6 → 0
# Batch 2: 1*2=2, 3*1=3 → 0
run_test "None eligible, V=100" "_test_03.txt" 2 100 "0 0"

echo ""
echo "--- Edge Cases ---"
# 1 order, 1 dispatcher, V=50 → 5*20=100✓ → 1
run_test "Single order, single dispatcher" "_test_04.txt" 1 50 "1"

# 1 order, 1 dispatcher, V=200 → 5*20=100 < 200 → 0
run_test "Single order, not eligible" "_test_04.txt" 1 200 "0"

echo ""
echo "--- Remainder / Uneven Split ---"
# 5 orders, 2 dispatchers → 2 + 3
# Batch 1 (orders 0-1): 10*10=100✓, 1*1=1 → 1
# Batch 2 (orders 2-4): 1*1=1, 1*1=1, 8*20=160✓ → 1
run_test "5 orders, 2 dispatchers (remainder)" "_test_05.txt" 2 50 "1 1"

# 7 orders, 3 dispatchers → 2+2+3
# Batch 1 (0-1): 3*20=60✓, 5*10=50✓ → 2
# Batch 2 (2-3): 2*5=10, 1*100=100✓ → 1
# Batch 3 (4-6): 4*30=120✓, 6*15=90✓, 10*10=100✓ → 3
run_test "7 orders, 3 dispatchers (remainder)" "_test_06.txt" 3 50 "2 1 3"

echo ""
echo "--- Equal Split ---"
# 4 orders, 4 dispatchers → 1 each
# 10*10=100✓, 1*1=1, 5*20=100✓, 2*3=6
run_test "4 orders, 4 dispatchers, V=50" "_test_07.txt" 4 50 "1 0 1 0"

echo ""
echo "--- Different V Values ---"
# 6 orders, 2 dispatchers, V=1000
# Batch 1 (0-2): 100*100=10000✓, 1*1=1, 50*50=2500✓ → 2
# Batch 2 (3-5): 2*2=4, 200*200=40000✓, 3*3=9 → 1
run_test "Large V=1000" "_test_08.txt" 2 1000 "2 1"

# 6 orders, 2 dispatchers, V=1 (all qualify)
run_test "V=1, all qualify" "_test_09.txt" 2 1 "3 3"

# 6 orders, 3 dispatchers, V=50 (5*10=50, exactly equal)
# Batch 1: 50✓, 50✓ → 2
# Batch 2: 50✓, 50✓ → 2
# Batch 3: 50✓, 50✓ → 2
run_test "Exact V boundary (50=50)" "_test_09.txt" 3 50 "2 2 2"

echo ""
echo "--- Single Dispatcher (all orders) ---"
# 5 orders, 1 dispatcher, V=50
# 3*10=30, 5*20=100✓, 2*30=60✓, 4*5=20, 1*70=70✓ → 3
run_test "All orders to 1 dispatcher" "_test_10.txt" 1 50 "3"

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

# Cleanup temp test files
rm -f _test_*.txt assignment3.o
