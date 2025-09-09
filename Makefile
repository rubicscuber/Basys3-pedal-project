GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) VHD_axis_i2s2.vhd
	@$(GHDL) -a $(FLAGS) VHD_axis_i2s2_TB.vhd
	@$(GHDL) -a $(FLAGS) VHD_axis_volume_controller.vhd
	@$(GHDL) -a $(FLAGS) rom.vhd
	@$(GHDL) -a $(FLAGS) VHD_top.vhd
	@$(GHDL) -a $(FLAGS) VHD_top_TB.vhd

	@$(GHDL) -e $(FLAGS) VHD_top_TB

	@$(GHDL) -r $(FLAGS) VHD_top_TB --wave=TOP_waveform.ghw --stop-time=1us
