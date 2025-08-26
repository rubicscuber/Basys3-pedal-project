library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VHD_axis_i2s2_TB is
end entity VHD_axis_i2s2_TB;

architecture RTL of VHD_axis_i2s2_TB is
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
   signal clock : std_logic;
   signal reset : std_logic;
   signal tx_s_data : std_logic_vector(31 downto 0);
   signal tx_s_valid : std_logic;
   signal tx_s_ready : std_logic;
   signal tx_s_last : std_logic;
   signal rx_m_data : std_logic_vector(31 downto 0);
   signal rx_m_valid : std_logic;
   signal rx_m_ready : std_logic;
   signal rx_m_last : std_logic;
   signal tx_mclk : std_logic;
   signal tx_lrck : std_logic;
   signal tx_sclk : std_logic;
   signal tx_sdout : std_logic;
   signal rx_mclk : std_logic;
   signal rx_lrck : std_logic;
   signal rx_sclk : std_logic;
   signal rx_sdin : std_logic;
begin
    UUT : component VHD_axis_i2s2
    port map(
        clock      => clock,
        reset      => reset,
        tx_s_data  => tx_s_data,
        tx_s_valid => tx_s_valid,
        tx_s_ready => tx_s_ready,
        tx_s_last  => tx_s_last,
        rx_m_data  => rx_m_data,
        rx_m_valid => rx_m_valid,
        rx_m_ready => rx_m_ready,
        rx_m_last  => rx_m_last,
        tx_mclk    => tx_mclk,
        tx_lrck    => tx_lrck,
        tx_sclk    => tx_sclk,
        tx_sdout   => tx_sdout,
        rx_mclk    => rx_mclk,
        rx_lrck    => rx_lrck,
        rx_sclk    => rx_sclk,
        rx_sdin    => rx_sdin
    );
    
    clockDriver : process
        constant period : time := 10 ps;
    begin
        clock <= '0';
        wait for period / 2;
        clock <= '1';
        wait for period / 2;
    end process clockDriver;

    RESET_PROC : process
    begin
        reset <= '1';
        wait for 10 ps;
        reset <= '0';
        wait;
    end process;
        

end architecture RTL;
