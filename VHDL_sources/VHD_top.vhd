library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----------------------------------------------------------
--
--
--
--
--
-----------------------------------------------------------

entity VHD_top is
    generic(
        BIT_WIDTH_G : integer := 16
    );
    port(
        clk     : in  std_logic;
        btnC    : in  std_logic;

        tx_mclk : out std_logic;
        tx_lrck : out std_logic;
        tx_sclk : out std_logic;
        tx_data : out std_logic;

        rx_mclk : out std_logic;
        rx_lrck : out std_logic;
        rx_sclk : out std_logic;
        rx_data : in  std_logic
    );
end entity VHD_top;

architecture VHD_top_ARCH of VHD_top is
    
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
    	generic(BIT_WIDTH_G : integer);
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

    --comment out for GHDL simulations
    component clk_wiz_0
        port(
            clk_in1  : in  std_logic;
            reset    : in  std_logic;
            clk_out1 : out std_logic
        );
    end component;

    signal axis_clock : std_logic;

    signal s_data_s  : std_logic_vector(31 downto 0);
    signal s_valid_s : std_logic;
    signal s_ready_s : std_logic;

    signal m_data_s  : std_logic_vector(31 downto 0);
    signal m_valid_s : std_logic;
    signal m_ready_s : std_logic;

begin

    axis_i2s2_inst : component VHD_axis_i2s2
        generic map(BIT_WIDTH_G => BIT_WIDTH_G)
        port map(
            clock      => axis_clock,
            reset      => btnC,

            tx_s_data_i  => s_data_s,
            tx_s_valid_i => s_valid_s,
            tx_s_ready_o => s_ready_s,

            rx_m_data_o  => m_data_s,
            rx_m_valid_o => m_valid_s,
            rx_m_ready_i => m_ready_s,

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
        generic map(BIT_WIDTH_G => BIT_WIDTH_G) --trying 16 bit LUT instead
        port map(
            clock        => axis_clock,
            reset        => btnC,

            s_axis_data_i  => m_data_s,
            s_axis_valid_i => m_valid_s,
            s_axis_ready_o => m_ready_s,

            m_axis_data_o  => s_data_s,
            m_axis_valid_o => s_valid_s,
            m_axis_ready_i => s_ready_s
        );

    axis_clock_gen : component clk_wiz_0
        port map(
            clk_in1  => clk,
            reset    => btnC,
            clk_out1 => axis_clock
        );
    --axis_clock <= clk; --testbenching only

end architecture VHD_top_ARCH;

