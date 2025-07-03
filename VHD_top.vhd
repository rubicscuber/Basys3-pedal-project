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
        tx_s_data  : in  std_logic_vector(31 downto 0);
        tx_s_valid : in  std_logic;
        tx_s_ready : out std_logic;
        tx_s_last  : in  std_logic;
        rx_m_data  : out std_logic_vector(31 downto 0);
        rx_m_valid : out std_logic;
        rx_m_ready : in  std_logic;
        rx_m_last  : out std_logic;
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
   
   component VHD_axis_volume_controller
    port(
        clock        : in  std_logic;
        reset        : in  std_logic;
        s_axis_data  : in  std_logic_vector(23 downto 0);
        s_axis_valid : in  std_logic;
        s_axis_ready : out std_logic;
        s_axis_last  : in  std_logic;
        m_axis_data  : out std_logic_vector(23 downto 0);
        m_axis_valid : out std_logic;
        m_axis_ready : in  std_logic;
        m_axis_last  : out std_logic
    );
   end component VHD_axis_volume_controller;

begin
    
end architecture VHD_top_ARCH;

