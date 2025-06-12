# ================================================================================ VARS
# project params
PRJ_DIR = $(realpath .)

# vivado run name
# vivado_run = run1_basys3_vga_controller_framebuffer
vivado_run = run2_nexysa7_vga_framebuffer

# synthesis and implementation dcp name
synth		= synth_$(vivado_run)
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

# ================================================================================ TARGETS imagemagick

old		:=
new		:=
depth	:= 4
colors	:= 64

resize:
	magick convert $(old) -resize 640x480 $(new)

truecolor_grade:
	magick convert ./images/mona_lisa.bmp -type truecolor -colors 2 -depth 1 -resize '640x480>' ./images/mona_lisa_truecolor_v1.bmp
	magick convert ./images/mona_lisa.bmp -type truecolor -colors 4 -depth 2 -resize '640x480>' ./images/mona_lisa_truecolor_v2.bmp
	magick convert ./images/mona_lisa.bmp -type truecolor -colors 8 -depth 3 -resize '640x480>' ./images/mona_lisa_truecolor_v3.bmp
	magick convert ./images/mona_lisa.bmp -type truecolor -colors 16 -depth 4 -resize '640x480>' ./images/mona_lisa_truecolor_v4.bmp
	magick convert ./images/philips_pm5544.png -type truecolor -colors 32 -resize '640x480>' ./images/philips_pm5544_32colors.png

grayscale_grade:
	magick convert ./images/mona_lisa.bmp -colorspace gray -colors 2 -depth 1 -resize '640x480>' ./images/mona_lisa_monochrome.bmp
	magick convert ./images/mona_lisa.bmp -colorspace gray -colors 4 -depth 2 -resize '640x480>' ./images/mona_lisa_gray_v2.bmp
	magick convert ./images/mona_lisa.bmp -colorspace gray -colors 8 -depth 3 -resize '640x480>' ./images/mona_lisa_gray_v3.bmp
	magick convert ./images/mona_lisa.bmp -colorspace gray -colors 16 -depth 4 -resize '640x480>' ./images/mona_lisa_gray_v4.bmp

# ================================================================================ TARGETS Vivado

# default target
default: help

# create vivado project
setup_prj_basys3:
	@ vivado -mode tcl -source ./scripts/setup_prj_basys3.tcl

setup_prj_nexysa7:
	@ vivado -mode tcl -source ./scripts/setup_prj_nexysa7.tcl

# run synthesis and implementation
run_vivado_basys3:
	@ rm -rf .gen .srcs
	@ vivado -mode batch -nojournal -notrace -stack 2000 \
		-source ./scripts/main_basys3.tcl -tclargs \
		$(synth) $(impl_1) $(impl_2) $(impl_3) $(impl_4) $(impl_5) $(bitstream)

run_vivado_nexysa7:
	@ rm -rf .gen .srcs
	@ vivado -mode batch -nojournal -notrace -stack 2000 \
		-source ./scripts/main_nexysa7.tcl -tclargs \
		$(synth) $(impl_1) $(impl_2) $(impl_3) $(impl_4) $(impl_5) $(bitstream)

# upload bitstream
upload_basys3:
	@ bash -c 'echo -e "$(GREEN) -------------------- Bitstream Upload ------------------- $(END)"'
	openFPGALoader --board basys3 --bitstream ./$(bitstream).bit
	@ bash -c 'echo -e "$(GREEN) --------------------------------------------------------- $(END)"'

upload_nexysa7:
	@ bash -c 'echo -e "$(GREEN) -------------------- Bitstream Upload ------------------- $(END)"'
	openFPGALoader --board nexys_a7_100 --bitstream ./$(bitstream).bit
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
	@ rm -rf nexys*
	@ rm -rf basys3*

clean_bin:
	rm -rf *.jou *.log *.str
	rm -rf xsim.dir *.vcd *.wdb *.zip *.xml *.pb
	rm -rf .gen .srcs
	rm -rf ./-p .Xil
	rm -rf ./data/*.json ./data/*.svg ./data/*.log
	rm -rf ./ip
	rm -rf ./bitstream*.bit

clean_all:
	@ make clean_checkpoints clean_logs clean_reports clean_testbenches
	@ make clean_projects
	@ make clean_bin

