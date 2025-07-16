library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VHD_top is
    port(
        clk : in std_logic;
        btnC : in std_logic;

        tx_mclk : out std_logic;
        tx_lrck : out std_logic;
        tx_sclk : out std_logic;
        tx_data : out std_logic;

        rx_mclk : out std_logic;
        rx_lrck : out std_logic;
        rx_sclk : out std_logic;
        rx_data : in std_logic
    );
end entity VHD_top;

architecture VHD_top_ARCH of VHD_top is

   component VHD_axis_i2s2
    port(
        clock      : in  std_logic;
        reset      : in  std_logic;

        --tx_s_data  : in  std_logic_vector(31 downto 0);
        --tx_s_valid : in  std_logic;
        --tx_s_ready : out std_logic;
        --tx_s_last  : in  std_logic;

        --rx_m_data  : out std_logic_vector(31 downto 0);
        --rx_m_valid : out std_logic;
        --rx_m_ready : in  std_logic;
        --rx_m_last  : out std_logic;

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
   
   component clk_wiz_0
    port(
        clk_in1 : in std_logic;
        reset : in std_logic;
        clk_out1 : out std_logic
    );
   end component;
   
   signal axis_clock : std_logic;
   
begin
    
    PASS_THROUGH : component VHD_axis_i2s2
        port map(
            clock    => axis_clock,
            reset    => btnC,

            tx_mclk  => tx_mclk,
            tx_lrck  => tx_lrck,
            tx_sclk  => tx_sclk,
            tx_sdout => tx_data,

            rx_mclk  => rx_mclk,
            rx_lrck  => rx_lrck,
            rx_sclk  => rx_sclk,
            rx_sdin  => rx_data
        );
        
    axis_clock_gen : component clk_wiz_0
        port map(
            clk_in1 => clk,
            reset => btnC,
            clk_out1 => axis_clock
        );
    
end architecture VHD_top_ARCH;

