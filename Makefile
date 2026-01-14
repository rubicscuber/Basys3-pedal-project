GHDL=ghdl
FLAGS="--std=08"
SRC_DIR := $(CURDIR)/VHDL_sources
SIM_DIR := $(CURDIR)/sim_sources

all:
	#######--------Assemble--------#######
	@$(GHDL) -a $(FLAGS) $(SRC_DIR)/VHD_axis_i2s2.vhd
	@$(GHDL) -a $(FLAGS) $(SRC_DIR)/VHD_axis_data_handler.vhd
	@$(GHDL) -a $(FLAGS) $(SRC_DIR)/nr_rom.vhd
	@$(GHDL) -a $(FLAGS) $(SRC_DIR)/VHD_top.vhd

	@$(GHDL) -a $(FLAGS) $(SIM_DIR)/VHD_axis_i2s2_TB.vhd
	@$(GHDL) -a $(FLAGS) $(SIM_DIR)/rom_TB.vhd
	@$(GHDL) -a $(FLAGS) $(SIM_DIR)/VHD_top_TB.vhd

	#######--------Enumerate--------#######
	@$(GHDL) -a $(FLAGS) $(SIM_DIR)/VHD_top_TB.vhd

	#######--------Record--------#######
	@$(GHDL) -r $(FLAGS) VHD_top_TB --wave=TOP_waveform.ghw --stop-time=15us
