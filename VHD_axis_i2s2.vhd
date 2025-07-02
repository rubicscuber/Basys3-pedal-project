library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VHD_axis_i2s2 is
    port(
        clock : in std_logic;
        reset : in std_logic;

        tx_s_data : in std_logic_vector(31 downto 0);
        tx_s_valid : in std_logic;
        tx_s_ready : out std_logic; --register
        tx_s_last : in std_logic;

        rx_m_data : out std_logic_vector(31 downto 0);
        rx_m_valid : out std_logic; --register
        rx_m_ready : in std_logic;
        rx_m_last : out std_logic; --register

        --clocks to keep i2s in slave mode on transmit side
        tx_mclk : out std_logic;
        tx_lrck : out std_logic;
        tx_sclk : out std_logic;
        tx_sdout : out std_logic; --register

        rx_mclk : out std_logic;
        rx_lrck : out std_logic;
        rx_sclk : out std_logic;
        rx_sdin : in std_logic
    );
end entity;


architecture behavioral of VHD_axis_i2s2 is

    constant EOF : integer := 455; --"111000111"
    signal count : unsigned(8 downto 0); 
    --signal lrck : std_logic;
    --signal sclk : std_logic;
    --signal mclk : std_logic;

    signal tx_data_l : std_logic_vector(31 downto 0);
    signal tx_data_r : std_logic_vector(31 downto 0);

    signal tx_data_l_shift : std_logic_vector(23 downto 0);
    signal tx_data_r_shift: std_logic_vector(23 downto 0);

    signal din_sync : std_logic;
    signal din_sync_shift : std_logic_vector(2 downto 0);

    signal rx_data_l_shift : std_logic_vector(23 downto 0);
    signal rx_data_r_shift : std_logic_vector(23 downto 0);
    signal rx_data_r : std_logic_vector(31 downto 0);
    signal rx_data_l : std_logic_vector(31 downto 0);

begin

    COUNTER : process(clock, reset) is
    begin
        if reset = '0' then
            count <= (others => '0');
        elsif rising_edge(clock) then
            count <= count + 1;
        end if;
    end process;

    --clock outputs to the i2s2 for slave mode
    tx_mclk <= clock;
    tx_lrck <= count(8);
    tx_sclk <= count(2);

    rx_mclk <= clock;
    rx_lrck <= count(8);
    rx_sclk <= count(2);

    --axis slave controllers
    AXIS_SLAVE_CONTROLLER : process(clock, reset) is 
    begin
        if reset = '0' then
            tx_s_ready <= '0';
        elsif rising_edge(clock) then
            if tx_s_ready = '1' and tx_s_valid = '1' and tx_s_last = '1' then
                tx_s_ready <= '0';
            elsif count = 0 then
                tx_s_ready <= '0';
            elsif count = EOF then
                tx_s_ready <= '1';
            end if;
        end if;
    end process;

    LOAD_TX_DATA_REGISTERS : process(clock, reset) is
    begin
        if reset = '0' then
            tx_data_r <= (others => '0');
            tx_data_l <= (others => '0');
        elsif rising_edge(clock) then
            if tx_s_valid = '1' and tx_s_ready = '1' then
                if tx_s_last = '1' then
                    tx_data_l <= tx_s_data;
                else 
                    tx_data_r <= tx_s_data;
                end if;
            end if;
        end if;
    end process;

    --i2s transmit shift registers
    SHIFT_DATA : process(clock, reset) is
    begin
        if reset = '0' then
            tx_data_l_shift <= (others => '0');
            tx_data_r_shift <= (others => '0');
        elsif rising_edge(clock) then

            if count = 7 then
                tx_data_l_shift <= tx_data_l(23 downto 0);
                tx_data_r_shift <= tx_data_r(23 downto 0);

            elsif count(2 downto 0) = 7 and    --"111"
                  count(7 downto 3) >= 1 and   --"00001"
                  count(7 downto 3) <= 24 then --"11000"

                if count(8) = '1' then --lrck
                    tx_data_l_shift <= tx_data_l_shift(22 downto 0) & '0';
                else
                    tx_data_r_shift <= tx_data_r_shift(22 downto 0) & '0';

                end if;
            end if;
        end if;
    end process;

    --i2s transmit shift registers
    SHIFT_DATA_CONCURRENT : process (clock) is 
    begin
        if rising_edge(clock) then
            if count(7 downto 3) >= 1 and 
               count(7 downto 3) <= 24 then

                if count(8) = '1' then
                    tx_sdout <= tx_data_l_shift(23);
                else
                    tx_sdout <= tx_data_r_shift(23);
                end if;

            else 
                tx_sdout <= '0';
            end if;
        end if;
    end process;

    --synch din to axis clock domain
    din_sync <= din_sync_shift(2);
    SYNC_SDIN : process(clock) is 
    begin
        if rising_edge(clock) then
            din_sync_shift <= din_sync_shift(1 downto 0) & rx_sdin;
        end if;
    end process;

    --receive shift registers
    RECEIVE_SHIFT_REGISTERS : process(clock) is 
    begin
        if rising_edge(clock) then
            if count(2 downto 0) = 3 and    --"011"
               count(7 downto 3) >= 1 and   --"00001"
               count(7 downto 3) <= 24 then --"11000"

                if count(8) = '1' then
                    rx_data_r_shift <= rx_data_r_shift(22 downto 0) & din_sync;
                else 
                    rx_data_l_shift <= rx_data_l_shift(22 downto 0) & din_sync;
                end if;
            end if;
        end if;
    end process;

    --axis master controllers
    LOAD_RX_DATA_REGISTERS : process(clock, reset) is
    begin
        if reset = '0' then
            rx_data_r <= (others => '0');
            rx_data_l <= (others => '0');
        elsif rising_edge(clock) then
            if count = EOF and rx_m_valid = '0' then
                rx_data_r <= "00000000" & rx_data_r_shift;
                rx_data_l <= "00000000" & rx_data_l_shift;
            end if;
        end if;
    end process;

    --multiplex between data_r and data_l based on status of last
    MUX_RX_MASTER_DATA : with rx_m_last select
        rx_m_data <= rx_data_r when '1',
                     rx_data_l when '0',
                     (others => '0') when others;
    
    RX_MASTER_VALID : process (clock, reset) is 
    begin
        if reset = '0' then
            rx_m_valid <= '0';
        elsif rising_edge(clock) then
            if count = EOF and rx_m_valid = '0' then
                rx_m_valid <= '1';
            elsif rx_m_valid = '1' and rx_m_ready = '1' and rx_m_last = '1' then
                rx_m_valid <= '0';
            end if;
        end if;
    end process;

    RX_MASTER_LAST : process(clock, reset) is
    begin
        if reset = '0' then
            rx_m_last <= '0';
        elsif rising_edge(clock) then
            if count = EOF and rx_m_valid = '0' then
                rx_m_last <= '0';
            elsif rx_m_valid = '1' and rx_m_ready = '1' then
                rx_m_last <= not rx_m_last;
            end if;
        end if;
    end process;

end architecture behavioral;
