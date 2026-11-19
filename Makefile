# ============================================================
# Makefile for Systolic Array UVM Verification
# Simulator: Synopsys VCS
# ============================================================

VCS       ?= vcs
VERDI     ?= verdi

TOP       ?= tb_top
TEST      ?= reset_idle_test

RTL       ?= pe.v project.v systolic_array.v

SIMV      := simv
LOG_DIR   := logs

BUILD_LOG := $(LOG_DIR)/compile.log
RUN_LOG   := $(LOG_DIR)/$(TEST).log

# ------------------------------------------------------------
# Testbench source files
# ------------------------------------------------------------

TB_FILES := interface.sv systolic_tb_pkg.sv tb_top.sv

# ------------------------------------------------------------
# VCS compilation flags
# ------------------------------------------------------------

VCS_FLAGS := -full64 -sverilog -ntb_opts uvm-1.2 \
             -timescale=1ns/1ps \
             -debug_access+all \
             -kdb \
             +incdir+.

# ------------------------------------------------------------
# All UVM testcases
# IMPORTANT: Names must match test class names in test.sv
# ------------------------------------------------------------

TESTS := reset_idle_test \
         reset_abort_test \
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

# ------------------------------------------------------------
# Phony targets
# ------------------------------------------------------------

.PHONY: all compile run run-all run-gui clean help check-rtl

all: compile

# ------------------------------------------------------------
# Check RTL files
# ------------------------------------------------------------

check-rtl:
	@if [ -z "$(strip $(RTL))" ]; then \
		echo "ERROR: Please specify RTL files."; \
		echo 'Example: make compile RTL="pe.v project.v systolic_array.v"'; \
		exit 1; \
	fi

# ------------------------------------------------------------
# Create log directory
# ------------------------------------------------------------

$(LOG_DIR):
	mkdir -p $(LOG_DIR)

# ------------------------------------------------------------
# Compile RTL and UVM testbench
# ------------------------------------------------------------

compile: check-rtl $(LOG_DIR)
	$(VCS) $(VCS_FLAGS) -top $(TOP) $(RTL) $(TB_FILES) \
		-o $(SIMV) -l $(BUILD_LOG)

# ------------------------------------------------------------
# Run one testcase
# Usage:
# make run TEST=reset_idle_test
# ------------------------------------------------------------

run:
	@if [ ! -x ./$(SIMV) ]; then \
		echo "Simulation executable not found. Run make compile first."; \
		exit 1; \
	fi
	./$(SIMV) +UVM_TESTNAME=$(TEST) \
		+UVM_VERBOSITY=UVM_MEDIUM \
		-l $(RUN_LOG)

# ------------------------------------------------------------
# Run all testcases sequentially
# Continue even if a testcase fails
# ------------------------------------------------------------

run-all: compile
	@failed=0; \
	for test in $(TESTS); do \
		echo ""; \
		echo "================================================"; \
		echo " Running UVM Test: $$test"; \
		echo "================================================"; \
		if ./$(SIMV) +UVM_TESTNAME=$$test \
			+UVM_VERBOSITY=UVM_MEDIUM \
			-l $(LOG_DIR)/$$test.log; then \
			echo "PASS: $$test"; \
		else \
			echo "FAIL: $$test"; \
			failed=1; \
		fi; \
	done; \
	echo ""; \
	echo "================================================"; \
	echo "              REGRESSION SUMMARY"; \
	echo "================================================"; \
	if [ $$failed -eq 0 ]; then \
		echo "ALL TESTS COMPLETED SUCCESSFULLY"; \
	else \
		echo "SOME TESTS FAILED. Check individual logs."; \
		exit 1; \
	fi

# ------------------------------------------------------------
# Run simulation and open Verdi
# ------------------------------------------------------------

run-gui: compile
	./$(SIMV) +UVM_TESTNAME=$(TEST) \
		+UVM_VERBOSITY=UVM_MEDIUM \
		+vcs+dumpvars+all \
		-l $(RUN_LOG)
	$(VERDI) -dbdir simv.daidir &

# ------------------------------------------------------------
# Clean generated files
# ------------------------------------------------------------

clean:
	rm -rf csrc simv simv.daidir *.vpd *.vcd *.fsdb *.log \
	       DVEfiles verdiLog novas.* ucli.key $(LOG_DIR)

# ------------------------------------------------------------
# Help
# ------------------------------------------------------------

help:
	@echo ""
	@echo "Systolic Array UVM Verification"
	@echo "================================"
	@echo ""
	@echo "Available commands:"
	@echo ""
	@echo "  make compile"
	@echo "      Compile RTL and UVM testbench"
	@echo ""
	@echo "  make run TEST=reset_idle_test"
	@echo "      Run one testcase"
	@echo ""
	@echo "  make run-all"
	@echo "      Compile once and run all testcases"
	@echo ""
	@echo "  make run-gui TEST=reset_idle_test"
	@echo "      Run simulation and open Verdi"
	@echo ""
	@echo "  make clean"
	@echo "      Remove generated files"
	@echo ""
	@echo "  make help"
	@echo "      Display this help"
	@echo ""
