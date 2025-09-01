library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VHD_top_TB is
end entity VHD_top_TB;

architecture behavioral of VHD_top_TB is
    
    component VHD_top is
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
            rx_data : in  std_logic --serial data input from PMOD i2s2 device
        );
    end component;

    signal clk : std_logic;
    signal btnC : std_logic;

    signal tx_mclk : std_logic;
    signal tx_lrck : std_logic;
    signal tx_sclk : std_logic;
    signal tx_data : std_logic;

    signal rx_mclk : std_logic;
    signal rx_lrck : std_logic;
    signal rx_sclk : std_logic;
    signal rx_data : std_logic;

    signal dataVector : std_logic_vector(23 downto 0);

begin

    UUT : component VHD_top
        port map(
            clk     => clk,
            btnC    => btnC,

            tx_mclk => tx_mclk,
            tx_lrck => tx_lrck,
            tx_sclk => tx_sclk,
            tx_data => tx_data,

            rx_mclk => rx_mclk,
            rx_lrck => rx_lrck,
            rx_sclk => rx_sclk,
            rx_data => rx_data
        );
    
    CLOCK_GEN : process
    begin
        clk <= '1';
        wait for 100 ps;
        clk <= '0';
        wait for 100 ps;
    end process;
    
    RESET_PROC : process
    begin
        btnC <= '1';
        wait for 100 ps;
        btnC <= '0';
        wait;
    end process;

    STIM : process
    begin
        dataVector <= std_logic_vector(to_unsigned(5697, 24));
        wait until rising_edge(tx_lrck);

        for i in 0 to 23 loop
            wait until rising_edge(tx_sclk);
            rx_data <= dataVector(i); --serial data input into axis_i2s2 component
        end loop;

    end process;

end architecture behavioral;
