#!/bin/bash

#===========================================
# 1. VCS COMPILATION
# ==========================================

echo "========================================"
echo "Starting VCS Compilation"
echo "========================================"

vcs -full64 -sverilog -ntb_opts uvm-1.2 \
-timescale=1ns/1ps \
-debug_access+all \
+cover=bcesf \
-l compile.log \
pe.v systolic_array.v project.v tb_top.sv \
-o simv

compile_status=$?

if [ $compile_status -ne 0 ]; then
    echo "COMPILATION FAILED. Regression aborted."
    exit 1
fi

echo "Compilation successful!"

# ==========================================
# 2. TEST LIST
# ==========================================

tests=(
    systolic_base_test
    reset_idle_test
    ena_check_test
    matrix_load_test
    done_load_test
    matrix_reload_test
    matrix_order_test
    arithmetic_test
)

LOG="regression.log"

# Clear previous regression log
> "$LOG"

# Track regression results
passed=0
failed=0

# ==========================================
# 3. RUN ALL TESTS
# ==========================================

for test in "${tests[@]}"
do
    echo ""
    echo "========================================"
    echo "Running test: $test"
    echo "========================================"

    echo -e "\n\n========== STARTING $test ==========\n" | tee -a "$LOG"

    ./simv \
    +UVM_TESTNAME=$test \
    +UVM_VERBOSITY=UVM_MEDIUM \
    +ntb_random_seed=1 \
    -cm line+cond+tgl+branch+fsm \
    -cm_dir ${test}_coverage.vdb 2>&1 | tee -a "$LOG"

    status=${PIPESTATUS[0]}

    if [ $status -eq 0 ]; then
        echo "$test : COMPLETED" | tee -a "$LOG"
        ((passed++))
    else
        echo "$test : FAILED (Exit code: $status)" | tee -a "$LOG"
        ((failed++))
    fi

    echo "========== FINISHED $test ==========" | tee -a "$LOG"

done

# ==========================================
# 4. REGRESSION SUMMARY
# ==========================================

echo ""
echo "========================================"
echo "REGRESSION SUMMARY"
echo "========================================"

echo "Total Tests : ${#tests[@]}" | tee -a "$LOG"
echo "Passed      : $passed" | tee -a "$LOG"
echo "Failed      : $failed" | tee -a "$LOG"

if [ $failed -eq 0 ]; then
    echo "REGRESSION COMPLETED SUCCESSFULLY" | tee -a "$LOG"
else
    echo "REGRESSION COMPLETED WITH FAILURES" | tee -a "$LOG"
fi

echo "========================================"

