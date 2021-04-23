// Copyright (C) 1953-2021 NUDT
// file name - Makefile 
// Version: Makefile_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//		  used to compile project to generate programming file.
//				 
///////////////////////////////////////////////////////////////////////////
.PHONY: all project clean

all: project run_synth run_fit run_asm run_sta run_eda
	@echo "compile finish"

project:
	quartus_sh -t create_project.tcl
run_synth:
	quartus_map TSN_FPGA_4port
run_fit:
	quartus_fit TSN_FPGA_4port
run_asm:
	quartus_asm TSN_FPGA_4port
run_sta:
	quartus_sta TSN_FPGA_4port
run_eda:
	quartus_eda TSN_FPGA_4port
	rm -rf *sopcinfo

clean:
	rm -rfv TSN_FPGA_4port.*
	rm -rfv output_files
	rm -rfv *db
