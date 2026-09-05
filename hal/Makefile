# SPDX-FileCopyrightText: 2026 Enio Kaljic
# SPDX-License-Identifier: CERN-OHL-S-2.0

SOURCEDIR = $(PWD)/src
BUILDDIR  = $(PWD)/build

RDLCSR    = csr
RDLSRC    = $(SOURCEDIR)/$(RDLCSR).rdl

PEAKRDLHEADER = $(BUILDDIR)/$(RDLCSR).h
PEAKRDLRTL    = $(BUILDDIR)/rtl/
PEAKRDLPYTHON = $(BUILDDIR)/python/
PEAKRDLMD     = $(BUILDDIR)/$(RDLCSR).md

all: $(PEAKRDLRTL) $(PEAKRDLPYTHON) $(PEAKRDLMD)

$(PEAKRDLRTL): $(RDLSRC)
	peakrdl regblock $^ -o $@ --cpuif avalon-mm-flat --top $(RDLCSR)

$(PEAKRDLPYTHON): $(RDLSRC)
	peakrdl python $^ -t $(RDLCSR) -o $@

$(PEAKRDLMD): $(RDLSRC)
	peakrdl markdown $^ -o $@ --top $(RDLCSR)

unittest: $(PEAKRDLPYTHON)
	python -W ignore::DeprecationWarning -m unittest discover -s $(PEAKRDLPYTHON)$(RDLCSR)/tests -t $(PEAKRDLPYTHON) -v

clean:
	rm -rf $(PEAKRDLRTL) $(PEAKRDLPYTHON) $(PEAKRDLMD)
