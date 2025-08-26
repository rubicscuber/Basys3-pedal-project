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

        m_axis_data  : out std_logic_vector(23 downto 0);
        m_axis_valid : out std_logic;
        m_axis_ready : in  std_logic;
        m_axis_last  : out std_logic;

        s_axis_data  : in  std_logic_vector(23 downto 0);
        s_axis_valid : in  std_logic;
        s_axis_ready : out std_logic;
        s_axis_last  : in  std_logic
    );
   end component VHD_axis_volume_controller;
   
   component clk_wiz_0
    port(
        clk_in1 : in std_logic;
        reset : in std_logic;
        clk_out1 : out std_logic
    );
   end component;
   
   signal axis_clock : std_logic;

   signal tx_s_data : std_logic_vector(31 downto 0);
   signal tx_s_valid : std_logic;
   signal tx_s_ready : std_logic;
   signal tx_s_last : std_logic;

   signal rx_m_data : std_logic_vector(31 downto 0);
   signal rx_m_valid : std_logic;
   signal rx_m_ready : std_logic;
   signal rx_m_last : std_logic;
   
begin
    
    axis_i2s : component VHD_axis_i2s2
        port map(
            clock    => axis_clock,
            reset    => btnC,

            tx_s_data => tx_s_data,
            tx_s_valid => tx_s_valid,
            tx_s_ready => tx_s_ready,
            tx_s_last => tx_s_last,

            rx_m_data => rx_m_data,
            rx_m_valid => rx_m_valid,
            rx_m_ready => rx_m_ready,
            rx_m_last => rx_m_last,

            tx_mclk  => tx_mclk,
            tx_lrck  => tx_lrck,
            tx_sclk  => tx_sclk,
            tx_sdout => tx_data,

            rx_mclk  => rx_mclk,
            rx_lrck  => rx_lrck,
            rx_sclk  => rx_sclk,
            rx_sdin  => rx_data
        );
    VHD_axis_volume_controller_inst : component VHD_axis_volume_controller
        port map(
            clock        => axis_clock,
            reset        => btnC,

            s_axis_data  => rx_m_data(31 downto 8),
            s_axis_valid => rx_m_valid,
            s_axis_ready => rx_m_ready,
            s_axis_last  => rx_m_last,

            m_axis_data  => tx_s_data(31 downto 8),
            m_axis_valid => tx_s_valid,
            m_axis_ready => tx_s_ready,
            m_axis_last  => tx_s_last
        );
    
        
    axis_clock_gen : component clk_wiz_0
        port map(
            clk_in1 => clk,
            reset => btnC,
            clk_out1 => axis_clock
        );
    
end architecture VHD_top_ARCH;

