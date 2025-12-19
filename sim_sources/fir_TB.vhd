library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity fir_TB is
end fir_TB;

architecture RTL of fir_TB is

    component VHD_axis_i2s2
        generic(BIT_WIDTH_G : integer);
        port(
            clock      : in  std_logic;
            reset      : in  std_logic;

            tx_s_data_i  : in  std_logic_vector(31 downto 0);
            tx_s_valid_i : in  std_logic;
            tx_s_ready_o : out std_logic;

            rx_m_data_o  : out std_logic_vector(31 downto 0);
            rx_m_valid_o : out std_logic;
            rx_m_ready_i : in  std_logic;

            tx_mclk    : out std_logic;
            tx_lrck    : out std_logic;
            tx_sclk    : out std_logic;
            tx_sdout   : out std_logic;

            rx_mclk    : out std_logic;
            rx_lrck    : out std_logic;
            rx_sclk    : out std_logic;
            rx_sdin    : in  std_logic
        );
    end component VHD_axis_i2s2;

    component VHD_axi_rom_interface
    	generic(
            BIT_WIDTH_G : integer;
            MIF_FILE_G : string
        );
    	port(
    		clock           : in  std_logic;
    		reset           : in  std_logic;

    		s_axis_data_i   : in  std_logic_vector(31 downto 0);
    		s_axis_valid_i  : in  std_logic;
    		s_axis_ready_o  : out std_logic;

    		m_axis_data_o   : out std_logic_vector(31 downto 0);
    		m_axis_valid_o  : out std_logic;
    		m_axis_ready_i  : in  std_logic
    	);
    end component VHD_axi_rom_interface;

    component parallel_FIR_filter
        generic(
            FILTER_TAPS  : integer               := 60;
            INPUT_WIDTH  : integer range 8 to 25 := 12;
            COEFF_WIDTH  : integer range 8 to 18 := 12;
            OUTPUT_WIDTH : integer range 8 to 43 := 12
        );
    port(
        clock        : in  STD_LOGIC;
        reset        : in  STD_LOGIC;

        s_axi_data_i : in  STD_LOGIC_VECTOR(INPUT_WIDTH - 1 downto 0);
        s_axi_valid_i  : in  std_logic;
        s_axi_ready_o  : out std_logic;

        m_axi_data_o : out STD_LOGIC_VECTOR(OUTPUT_WIDTH - 1 downto 0);
        m_axi_valid_o  : out std_logic;
        m_axi_ready_i  : in  std_logic
    );
    end component parallel_FIR_filter; 

    constant FILTER_TAPS  : integer               := 60;
    constant INPUT_WIDTH  : integer range 8 to 25 := 12;
    constant COEFF_WIDTH  : integer range 8 to 18 := 12;
    constant OUTPUT_WIDTH : integer range 8 to 43 := 12;
    constant DATA_WIDTH : integer := 12;

    constant DATA_FILE : string := "tanh_12x4096.mif";

    signal clock : std_logic;
    signal reset : std_logic;

    signal i2s2_data_in_s : std_logic_vector(31 downto 0);
    signal i2s2_valid_in_s : std_logic;
    signal i2s2_ready_out_s : std_logic;

    signal i2s2_data_out_s : std_logic_vector(31 downto 0);
    signal i2s2_valid_out_s : std_logic;
    signal i2s2_ready_in_s : std_logic;

    signal rom_data_out_s : std_logic_vector(31 downto 0);
    signal rom_valid_out_s : std_logic;
    signal rom_ready_in_s : std_logic;

    signal tx_mclk : std_logic;
    signal tx_lrck : std_logic;
    signal tx_sclk : std_logic;
    signal tx_data : std_logic;

    signal rx_mclk : std_logic;
    signal rx_lrck : std_logic;
    signal rx_sclk : std_logic;
    signal rx_data : std_logic;

    --type test_vector_typ is array (0 to (2**16-1)) of std_logic_vector(15 downto 0);

    --impure function InitTestVector (FileName : in string) return test_vector_typ is
    --    FILE RomFile : text open READ_MODE is FileName;
    --    variable RomFileLine : line;
    --    variable ROM_MEMORY : test_vector_typ;
    --    variable temp_data : bit_vector(15 downto 0);
    --begin
    --    for i in test_vector_typ'range loop
    --        readline(RomFile, RomFileLine); 
    --        read(RomFileLine, temp_data);
    --        ROM_MEMORY(i) := to_stdlogicvector(temp_data);
    --    end loop;

    --    return ROM_MEMORY;
    --end function;

    --constant test_vector : test_vector_typ := InitTestVector(DATA_FILE);

    signal sdataVector : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    axis_i2s2_inst : component VHD_axis_i2s2
        generic map(BIT_WIDTH_G => DATA_WIDTH)
        port map(
            clock      => clock,
            reset      => reset,

            tx_s_data_i  => i2s2_data_in_s,
            tx_s_valid_i => i2s2_valid_in_s,
            tx_s_ready_o => i2s2_ready_out_s,

            rx_m_data_o  => i2s2_data_out_s,
            rx_m_valid_o => i2s2_valid_out_s,
            rx_m_ready_i => i2s2_ready_in_s,

            tx_mclk    => tx_mclk,
            tx_lrck    => tx_lrck,
            tx_sclk    => tx_sclk,
            tx_sdout   => tx_data,

            rx_mclk    => rx_mclk,
            rx_lrck    => rx_lrck,
            rx_sclk    => rx_sclk,
            rx_sdin    => rx_data
        );

    axi_rom_interface_inst : component VHD_axi_rom_interface
        generic map(
            BIT_WIDTH_G => DATA_WIDTH,
            MIF_FILE_G  => DATA_FILE
        )
        port map(
            clock        => clock,
            reset        => reset,

            s_axis_data_i  => i2s2_data_out_s,
            s_axis_valid_i => i2s2_valid_out_s,
            s_axis_ready_o => i2s2_ready_in_s,

            m_axis_data_o  => rom_data_out_s,
            m_axis_valid_o => rom_valid_out_s,
            m_axis_ready_i => rom_ready_in_s
        );

    FIR_INST : parallel_FIR_filter
        generic map(
            FILTER_TAPS  => FILTER_TAPS,
            INPUT_WIDTH  => INPUT_WIDTH,
            COEFF_WIDTH  => COEFF_WIDTH,
            OUTPUT_WIDTH => OUTPUT_WIDTH
        )
        port map(
            clock        => clock,
            reset        => reset,

            s_axi_data_i => rom_data_out_s(31 downto 32-DATA_WIDTH),
            s_axi_valid_i  => rom_valid_out_s,
            s_axi_ready_o  => rom_ready_in_s,

            m_axi_data_o => i2s2_data_in_s(31 downto 32-DATA_WIDTH),
            m_axi_valid_o  => i2s2_valid_in_s,
            m_axi_ready_i  => i2s2_ready_out_s
        );

    CLOCK_GEN : process
    begin
        clock <= '1';
        wait for 10 ps;
        clock <= '0';
        wait for 100 ps;
    end process;
    
    RESET_PROC : process
    begin
        reset <= '1';
        wait for 10 ps;
        reset <= '0';
        wait;
    end process;

    STIM : process
    begin
        --i is signed range from negative to positive values
        for i in (-1)*(2**DATA_WIDTH)/2 to (2**DATA_WIDTH)/2-1 loop

            --write values from -range to +range
            sdataVector <= std_logic_vector(to_signed(i,DATA_WIDTH));
            wait until rising_edge(tx_lrck);

            for j in DATA_WIDTH-1 downto 0 loop --msb arrives first
                wait until rising_edge(tx_sclk);
                rx_data <= sdataVector(j); --serial input acting from ADC
            end loop;
        end loop;
    end process;

end architecture RTL;
