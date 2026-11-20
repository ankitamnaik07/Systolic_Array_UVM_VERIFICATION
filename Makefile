
#=====================================================================
# VCS / UVM Regression Makefile
# Systolic Array UVM Verification
#=====================================================================

# ---- Config ---------------------------------------------------------

VCS           ?= vcs
URG           ?= urg
TOP           ?= tb_top

TESTLIST ?= \
        reset_idle_test \
        reset_abort_test \
	reset_state_test \
        ena_check_test \
        matrix_load_test \
        done_load_test \
        matrix_reload_test \
        matrix_order_test \
        arithmetic_test \
        overflow_test \
        read_wrap_test \
        data_retain_test \
        random_test \
        priority_test \
        wb_start_test \
        invalid_req_test \
        load_length_test \
        back2back_test \
        upper_bits_test \
        read_retain_test

NUM_RUNS       ?= 1
SEED_LIST      ?= 1 10 25 50 100

UVM_VERBOSITY  ?= UVM_LOW
UVM_TIMEOUT    ?= 2000000

PER_RUN_REPORT ?= 0

# ---- Coverage options -----------------------------------------------

CM_OPTS = -cm line+cond+fsm+tgl+branch+assert

DESIGN_VDB ?= simv.vdb

# ---- Output directories ---------------------------------------------

SINGLE_ROOT ?= single_runs

REGR_ROOT        ?= regression_cm
REGR_RUNS_DIR     = $(REGR_ROOT)/runs
REGR_MERGED_DIR   = $(REGR_ROOT)/merged
REGR_MERGED       = $(REGR_MERGED_DIR)/simv
REGR_REPORT       = $(REGR_MERGED_DIR)/report

# ---- RTL source files -----------------------------------------------

RTL_SRCS = \
        pe.v \
        systolic_array.v \
        project.v

# ---- Testbench source files -----------------------------------------

TB_SRCS = \
        interface.sv \
        systolic_tb_pkg.sv \
        tb_top.sv

ALL_SRCS = $(RTL_SRCS) $(TB_SRCS)

# ---- VCS compile options --------------------------------------------

VCS_FLAGS = -full64 -sverilog -ntb_opts uvm -licqueue \
            -debug_access+all \
            -assert svaext -lca -assert enable_diag \
            $(CM_OPTS)

SIMV = simv

# ---- Phony targets ---------------------------------------------------

.PHONY: all vcs run regression regression_seeds \
        merge_regression clean clean_regression help

# ---- Default target --------------------------------------------------

all: vcs

#=====================================================================
# COMPILE
#=====================================================================

vcs:
	@echo "=================================================="
	@echo " Compiling Systolic Array UVM Environment"
	@echo "=================================================="

	$(VCS) $(VCS_FLAGS) \
	    $(ALL_SRCS) \
	    -top $(TOP) \
	    -o $(SIMV) \
	    -l compile.log

	@echo ">>> Compilation completed. Check compile.log"

#=====================================================================
# RUN SINGLE TEST
#=====================================================================

# Usage:
# make run TEST=matrix_load_test
# make run TEST=matrix_load_test SEED=42

run:
ifndef TEST
	$(error Usage: make run TEST=<test_name> [SEED=<n>])
endif

	@rm -rf $(SINGLE_ROOT)/$(TEST)
	@mkdir -p $(SINGLE_ROOT)/$(TEST)

	./$(SIMV) $(CM_OPTS) \
	    -cm_dir $(SINGLE_ROOT)/$(TEST)/simv.vdb \
	    +UVM_TESTNAME=$(TEST) \
	    +UVM_VERBOSITY=$(UVM_VERBOSITY) \
	    +UVM_TIMEOUT=$(UVM_TIMEOUT) \
	    $(if $(SEED),+ntb_random_seed=$(SEED)) \
	    -l $(SINGLE_ROOT)/$(TEST)/$(TEST).log

	$(URG) -dir $(DESIGN_VDB) \
	    $(SINGLE_ROOT)/$(TEST)/simv.vdb \
	    -report $(SINGLE_ROOT)/$(TEST)/report

	@echo ">>> Test log       : $(SINGLE_ROOT)/$(TEST)/$(TEST).log"
	@echo ">>> Coverage DB    : $(SINGLE_ROOT)/$(TEST)/simv.vdb"
	@echo ">>> Coverage report: $(SINGLE_ROOT)/$(TEST)/report/dashboard.html"

#=====================================================================
# AUTOMATIC SEED REGRESSION
#=====================================================================

# Runs every test NUM_RUNS times using automatic random seeds.

regression:
	@mkdir -p $(REGR_RUNS_DIR)
	@rm -f $(REGR_ROOT)/vdb_list.txt $(REGR_ROOT)/failed_runs.txt

	@for t in $(TESTLIST); do \
	    for i in $$(seq 1 $(NUM_RUNS)); do \
	        run_dir=$(REGR_RUNS_DIR)/$${t}_run$${i}; \
	        vdb=$$run_dir/simv.vdb; \
	        log=$$run_dir/$${t}_run$${i}.log; \
	        rm -rf $$run_dir; \
	        mkdir -p $$run_dir; \
	        echo "=================================================="; \
	        echo "Running $$t (run $$i / $(NUM_RUNS))"; \
	        echo "=================================================="; \
	        ./$(SIMV) $(CM_OPTS) -cm_dir $$vdb \
	            +UVM_TESTNAME=$$t \
	            +UVM_VERBOSITY=$(UVM_VERBOSITY) \
	            +UVM_TIMEOUT=$(UVM_TIMEOUT) \
	            +ntb_random_seed_automatic \
	            -l $$log; \
	        status=$$?; \
	        if grep -qE "UVM_FATAL *: *[1-9]|UVM_ERROR *: *[1-9]" $$log 2>/dev/null; then \
	            status=1; \
	        fi; \
	        if [ $$status -ne 0 ]; then \
	            echo "$$t run $$i (exit=$$status) -> $$log" >> $(REGR_ROOT)/failed_runs.txt; \
	            echo "!!! $$t run $$i FAILED - see $$log"; \
	        else \
	            echo ">>> $$t run $$i PASSED"; \
	        fi; \
	        if [ -d $$vdb ] && [ -n "$$(ls -A $$vdb 2>/dev/null)" ]; then \
	            echo $$vdb >> $(REGR_ROOT)/vdb_list.txt; \
	        else \
	            echo "!!! $$t run $$i produced no coverage DB"; \
	            echo "$$t run $$i (NO VDB) -> $$log" >> $(REGR_ROOT)/failed_runs.txt; \
	        fi; \
	        if [ "$(PER_RUN_REPORT)" = "1" ] && [ -d $$vdb ]; then \
	            $(URG) -dir $(DESIGN_VDB) $$vdb -report $$run_dir/report > /dev/null 2>&1; \
	        fi; \
	    done; \
	done

	@$(MAKE) merge_regression

#=====================================================================
# USER-DEFINED MULTI-SEED REGRESSION
#=====================================================================

# Runs every test with every seed in SEED_LIST.
#
# Usage:
# make regression_seeds
# make regression_seeds SEED_LIST="1 5 10 20"
# make regression_seeds TESTLIST="matrix_load_test matrix_reload_test"

regression_seeds:
	@mkdir -p $(REGR_RUNS_DIR)
	@rm -f $(REGR_ROOT)/vdb_list.txt $(REGR_ROOT)/failed_runs.txt

	@echo "=================================================="
	@echo " MULTI-SEED REGRESSION"
	@echo " Seeds: $(SEED_LIST)"
	@echo " Tests: $(words $(TESTLIST))"
	@echo "=================================================="

	@for t in $(TESTLIST); do \
	    for seed in $(SEED_LIST); do \
	        run_dir=$(REGR_RUNS_DIR)/$${t}_seed$${seed}; \
	        vdb=$$run_dir/simv.vdb; \
	        log=$$run_dir/$${t}_seed$${seed}.log; \
	        rm -rf $$run_dir; \
	        mkdir -p $$run_dir; \
	        echo "=================================================="; \
	        echo "Running $$t with SEED=$$seed"; \
	        echo "=================================================="; \
	        ./$(SIMV) $(CM_OPTS) -cm_dir $$vdb \
	            +UVM_TESTNAME=$$t \
	            +UVM_VERBOSITY=$(UVM_VERBOSITY) \
	            +UVM_TIMEOUT=$(UVM_TIMEOUT) \
	            +ntb_random_seed=$$seed \
	            -l $$log; \
	        status=$$?; \
	        if grep -qE "UVM_FATAL *: *[1-9]|UVM_ERROR *: *[1-9]" $$log 2>/dev/null; then \
	            status=1; \
	        fi; \
	        if [ $$status -ne 0 ]; then \
	            echo "$$t seed $$seed (exit=$$status) -> $$log" >> $(REGR_ROOT)/failed_runs.txt; \
	            echo "!!! FAILED: $$t seed $$seed"; \
	        else \
	            echo ">>> PASSED: $$t seed $$seed"; \
	        fi; \
	        if [ -d $$vdb ] && [ -n "$$(ls -A $$vdb 2>/dev/null)" ]; then \
	            echo $$vdb >> $(REGR_ROOT)/vdb_list.txt; \
	        else \
	            echo "!!! $$t seed $$seed produced no coverage DB"; \
	            echo "$$t seed $$seed (NO VDB) -> $$log" >> $(REGR_ROOT)/failed_runs.txt; \
	        fi; \
	    done; \
	done

	@$(MAKE) merge_regression

#=====================================================================
# MERGE COVERAGE
#=====================================================================

merge_regression:
	@if [ ! -s $(REGR_ROOT)/vdb_list.txt ]; then \
	    echo "!!! No coverage DBs to merge. Check logs."; \
	    exit 1; \
	fi

	@echo ">>> Merging coverage databases..."

	@rm -rf $(REGR_MERGED_DIR)
	@mkdir -p $(REGR_MERGED_DIR)

	$(URG) -dir $(DESIGN_VDB) \
	    $$(cat $(REGR_ROOT)/vdb_list.txt) \
	    -dbname $(REGR_MERGED) \
	    -report $(REGR_REPORT)

	@echo ">>> Merged DB   : $(REGR_MERGED).vdb"
	@echo ">>> HTML report : $(REGR_REPORT)/dashboard.html"

	@if [ -s $(REGR_ROOT)/failed_runs.txt ]; then \
	    echo ">>> Some regression runs failed."; \
	    cat $(REGR_ROOT)/failed_runs.txt; \
	else \
	    echo ">>> All regression runs passed."; \
	fi

#=====================================================================
# CLEAN
#=====================================================================

clean:
	rm -rf simv simv.daidir csrc *.log $(DESIGN_VDB) \
	       urgReport DVEfiles ucli.key \
	       $(SINGLE_ROOT) vc_hdrs.h

clean_regression:
	rm -rf $(REGR_ROOT)

#=====================================================================
# HELP
#=====================================================================

help:
	@echo ""
	@echo " Systolic Array UVM Verification"
	@echo ""
	@echo " make vcs"
	@echo "     Compile"
	@echo ""
	@echo " make run TEST=matrix_load_test"
	@echo "     Run one test"
	@echo ""
	@echo " make run TEST=matrix_reload_test SEED=42"
	@echo "     Run one test with a specific seed"
	@echo ""
	@echo " make regression"
	@echo "     Automatic seed regression"
	@echo ""
	@echo " make regression NUM_RUNS=10"
	@echo "     Automatic regression with 10 runs per test"
	@echo ""
	@echo " make regression_seeds"
	@echo "     Run all tests with predefined seeds"
	@echo ""
	@echo " make regression_seeds SEED_LIST='1 5 10 20'"
	@echo "     Run all tests with selected seeds"
	@echo ""
	@echo " make regression_seeds TESTLIST='matrix_load_test matrix_reload_test' SEED_LIST='1 10'"
	@echo "     Run selected tests with selected seeds"
	@echo ""
	@echo " make merge_regression"
	@echo "     Merge existing coverage databases"
	@echo ""
	@echo " make clean"
	@echo "     Clean simulation files"
	@echo ""
	@echo " make clean_regression"
	@echo "     Clean regression results"
	@echo ""
	@echo " Total tests: $(words $(TESTLIST))"
	@echo " Default seed list: $(SEED_LIST)"
	@echo ""

