# ================================================================================ VARS
# project params
PRJ_DIR = $(realpath .)

# vivado run name
vivado_run = run1_basys3_vga_controller_framebuffer

# synthesis and implementation dcp name
synth		= synthesis_$(vivado_run)
impl_1		= impl_s1_opt_design_$(vivado_run)
impl_2		= impl_s2_power_opt_design_$(vivado_run)
impl_3		= impl_s3_place_design_$(vivado_run)
impl_4		= impl_s4_phys_opt_design_$(vivado_run)
impl_5		= impl_s5_route_design_$(vivado_run)
bitstream	= bitstream_$(vivado_run)

# shell colors
GREEN=\033[0;32m
RED=\033[0;31m
BLUE=\033[0;34m
END=\033[0m

# ================================================================================ TARGETS Vivado

# default target
default: help

# create vivado project
setup_prj_vivado:
	@ vivado -mode tcl -source ./scripts/setup_prj_basys3.tcl

# run synthesis and implementation
run_vivado:
	@ rm -rf .gen .srcs
	@ vivado -mode batch -nojournal -notrace -stack 2000 \
		-source ./scripts/main_basys3.tcl -tclargs \
		$(synth) \
		$(impl_1) $(impl_2) $(impl_3) $(impl_4) $(impl_5) $(bitstream)

upload:
	@ bash -c 'echo -e "$(GREEN) -------------------- Bitstream Upload ------------------- $(END)"'
	openFPGALoader --board basys3 --bitstream ./$(bitstream).bit
	@ bash -c 'echo -e "$(GREEN) --------------------------------------------------------- $(END)"'

# ================================================================================ clean
clean_checkpoints:
	@ rm -rf ./bin/checkpoints

clean_logs:
	@ rm -rf ./bin/logs

clean_reports:
	@ rm -rf ./bin/reports

clean_testbenches:
	@ rm -rf ./bin/testbench

clean_projects:
	@ rm -rf nexysa7_100t*
	@ rm -rf nexys_video*
	@ rm -rf basys3*

clean_bin:
	rm -rf *.jou *.log *.str
	rm -rf xsim.dir *.vcd *.wdb *.zip *.xml *.pb
	rm -rf .gen .srcs
	rm -rf ./-p .Xil
	rm -rf ./data/*.json ./data/*.svg ./data/*.log

clean_all:
	@ make clean_checkpoints clean_logs clean_reports clean_testbenches
	@ make clean_projects
	@ make clean_bin

