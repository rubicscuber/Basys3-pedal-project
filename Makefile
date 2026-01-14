GHDL=ghdl
FLAGS="--std=08"
SRC_DIR := $(CURDIR)/VHDL_sources
SIM_DIR := $(CURDIR)/sim_sources

all:
	#######--------Assemble--------#######
	@$(GHDL) -a $(FLAGS) $(SRC_DIR)/VHD_axis_i2s2.vhd
	@$(GHDL) -a $(FLAGS) $(SRC_DIR)/VHD_axi_rom_interface.vhd
	@$(GHDL) -a $(FLAGS) $(SRC_DIR)/nr_rom.vhd
	@$(GHDL) -a $(FLAGS) $(SRC_DIR)/parallel_FIR_filter.vhd
	@$(GHDL) -a $(FLAGS) $(SRC_DIR)/VHD_top.vhd

	@$(GHDL) -a $(FLAGS) $(SIM_DIR)/VHD_axis_i2s2_TB.vhd
	@$(GHDL) -a $(FLAGS) $(SIM_DIR)/rom_TB.vhd
	@$(GHDL) -a $(FLAGS) $(SIM_DIR)/fir_TB.vhd
	@$(GHDL) -a $(FLAGS) $(SIM_DIR)/VHD_top_TB.vhd

	#######--------Enumerate--------#######
	@$(GHDL) -a $(FLAGS) $(SIM_DIR)/fir_TB.vhd

	#######--------Record--------#######
	@$(GHDL) -r $(FLAGS) fir_TB --wave=fir_waveform.ghw --stop-time=1us
