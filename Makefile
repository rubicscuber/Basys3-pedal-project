GHDL=ghdl
FLAGS="--std=08"

all:
	@$(GHDL) -a $(FLAGS) VHD_axis_i2s2.vhd
	@$(GHDL) -a $(FLAGS) axis_i2s2_testbench.vhd

	@$(GHDL) -e $(FLAGS) axis_i2s2_testbench

	@$(GHDL) -r $(FLAGS) axis_i2s2_testbench --wave=I2S2_Waveform.ghw --stop-time=25us