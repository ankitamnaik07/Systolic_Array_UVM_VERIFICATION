
#!/bin/bash

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

for test in "${tests[@]}"
do
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
    else
        echo "$test : FAILED (Exit code: $status)" | tee -a "$LOG"
    fi

    echo "========== FINISHED $test ==========" | tee -a "$LOG"

done

echo "========================================"
echo "ALL TESTS COMPLETED"
echo "========================================" | tee -a "$LOG"

