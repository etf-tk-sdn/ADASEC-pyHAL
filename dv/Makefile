# SPDX-FileCopyrightText: 2026 Enio Kaljic
# SPDX-License-Identifier: CERN-OHL-S-2.0

TOPLEVEL_LANG = verilog
SIM = verilator

ROOT_DIR      = $(abspath $(CURDIR)/..)
PEAKRDLRTL    = $(ROOT_DIR)/hal/build/rtl
PEAKRDLPYTHON = $(ROOT_DIR)/hal/build/python
RTL_DIR       = $(ROOT_DIR)/rtl

# Top-level module
TOPLEVEL = adasec_top_tb

# RTL sources
VERILOG_SOURCES += $(PEAKRDLRTL)/csr_pkg.sv
VERILOG_SOURCES += $(PEAKRDLRTL)/csr.sv
VERILOG_SOURCES += $(RTL_DIR)/avalon_st_adapter.sv
VERILOG_SOURCES += $(RTL_DIR)/avalon_st_fifo.sv
VERILOG_SOURCES += $(RTL_DIR)/avalon_st_fifo_adapter.sv
VERILOG_SOURCES += $(RTL_DIR)/adasec_top.sv
VERILOG_SOURCES += $(CURDIR)/adasec_top_tb.sv

# cocotb test module (without .py)
COCOTB_TEST_MODULES = testbench

# Build outputs
SIM_OUTPUT = $(ROOT_DIR)/build/dv
SIM_BUILD = $(SIM_OUTPUT)/sim_build

# Verilator flags
EXTRA_ARGS += --sv
EXTRA_ARGS += --trace
EXTRA_ARGS += --trace-fst
EXTRA_ARGS += --trace-structs
EXTRA_ARGS += -Wall -Wno-fatal $(CURDIR)/config.vlt

# Python path
export PYTHONPATH := $(CURDIR):$(PEAKRDLPYTHON):$(PYTHONPATH)

# cocotb
include $(shell cocotb-config --makefiles)/Makefile.sim

# View waveform
wave:
	gtkwave dump.fst

# Hardware test
hwtest:
	python -m hardware_test

# Extended clean
clean::
	@rm -rf __pycache__
	@rm -f *.pyc
