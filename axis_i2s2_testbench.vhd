library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_i2s2_testbench is
end entity axis_i2s2_testbench;

architecture behavioral of axis_i2s2_testbench is

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
   signal reset : std_logic := '0';

   signal tx_s_data : std_logic_vector(31 downto 0) := (others => '0');
   signal tx_s_valid : std_logic := '0';
   signal tx_s_ready : std_logic;
   signal tx_s_last : std_logic := '0';

   signal rx_m_data : std_logic_vector(31 downto 0);
   signal rx_m_valid : std_logic;
   signal rx_m_ready : std_logic := '0';
   signal rx_m_last : std_logic;

   signal tx_mclk : std_logic;
   signal tx_lrck : std_logic;
   signal tx_sclk : std_logic;
   signal tx_sdout : std_logic;

   signal rx_mclk : std_logic;
   signal rx_lrck : std_logic;
   signal rx_sclk : std_logic;
   signal rx_sdin : std_logic := '0';
   
begin

    UUT : component VHD_axis_i2s2 port map(
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


    RESET_GEN : process is
    begin
        reset <= '0';
        wait for 5 ns;
        reset <= '1';
        wait;
    end process;

    CLOCK_GEN : process is 
    begin
        clock <= '1';
        wait for 5 ns;
        clock <= '0';
        wait for 5 ns;
    end process;

    STIMULUS : process is
    begin

        tx_s_data <= (others => '0');
        wait until rising_edge(clock);

        wait until rising_edge(tx_s_ready); --send Left Data
        tx_s_data <= std_logic_vector(to_unsigned(913, 32));
        tx_s_valid <= '1';
        tx_s_last <= '1';
        wait until rising_edge(clock);
        tx_s_data <= (others => '0');
        tx_s_valid <= '0';
        tx_s_last <= '0';
        wait until rising_edge(clock);

        wait until rising_edge(tx_s_ready); 
        tx_s_data <= std_logic_vector(to_unsigned(5046, 32));
        tx_s_valid <= '1';
        tx_s_last <= '1';
        wait until rising_edge(clock);
        tx_s_data <= (others => '0');
        tx_s_valid <= '0';
        tx_s_last <= '0';
        wait until rising_edge(clock);

        wait;
    end process;

end architecture behavioral;

