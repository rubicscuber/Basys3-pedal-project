library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VHD_axis_volume_controller is
    port(
        clock : in std_logic;
        reset : in std_logic;

        m_axis_data : out std_logic_vector(23 downto 0);
        m_axis_valid : out std_logic;
        m_axis_ready : in std_logic;
        m_axis_last : out std_logic;

        s_axis_data : in std_logic_vector(23 downto 0);
        s_axis_valid : in std_logic;
        s_axis_ready : out std_logic;
        s_axis_last : in std_logic
    );
end entity VHD_axis_volume_controller;

architecture VHD_axis_volume_controller_ARCH of VHD_axis_volume_controller is

    type data_array is array (integer range <>) of std_logic_vector(31 downto 0);
    signal data : data_array(0 to 1);

    --signal s_select : integer range 0 to 1;
    signal s_new_word : std_logic;
    signal s_new_packet : std_logic;
    signal s_new_packet_r : std_logic;
    signal m_new_word : std_logic;
    signal m_new_packet : std_logic;

begin

    S_NEW_WORD_PACKET : process(clock) is
    begin
        if rising_edge(clock) then
            if s_axis_valid = '1' and s_axis_ready = '1' then
                if s_axis_last = '1' then
                    s_new_packet <= '1';
                else 
                    s_new_packet <= '0';
                end if;
                s_new_word <= '1';
            else
                s_new_word <= '0';
            end if;
        end if;
    end process;

    --shift new_packet flag into register
    S_NEW_PACKET_SHIFT : process(clock) is
    begin
        if rising_edge(clock) then
            s_new_packet_r <= s_new_packet;
        end if;
    end process;
    
    LOAD_DATA_REGISTER : process(clock) is
    begin
        if rising_edge(clock) then
            if s_new_packet_r = '1' then
                data(0) <= s_axis_data & "00000000";
            end if;
        end if;
    end process;

    M_NEW_WORD_PACKET : process(clock) is
    begin
        if rising_edge(clock) then
            if m_axis_valid = '1' and m_axis_ready = '1' then
                m_new_word <= '1';
                if m_axis_last = '1' then
                    m_new_packet <= '1';
                else 
                    m_new_packet <= '0';
                end if;
            else
                m_new_word <= '0';
            end if;
        end if;
    end process;

    M_AXIS_VALID_PROC : process(clock)
    begin
        if rising_edge(clock) then
            if s_new_packet_r = '1' then
                m_axis_valid <= '1';
            elsif m_new_packet = '1' then
                m_axis_valid <= '0';
            end if;
        end if;
    end process;

    M_AXIS_LAST_PROC : process(clock)
    begin
        if rising_edge(clock) then
            if m_new_packet = '1' then
                m_axis_last <= '0';
            elsif m_new_word = '1' then
                m_axis_last <= '1';
            end if;
        end if;
    end process;

    TRANSMIT_DATA : process(clock)
    begin
        if rising_edge(clock) then
            if M_axis_valid = '1' then
                m_axis_data <= data(0)(31 downto 8);
            else
                data(0) <= (others => '0');
            end if;
        end if;
    end process;

    S_AXIS_READY_PROC : process(clock) 
    begin
        if rising_edge(clock) then
            if s_new_packet = '1' then
                s_axis_ready <= '0';
            elsif m_new_packet = '1' then
                s_axis_ready <= '1';
            end if;
        end if;
    end process;

end architecture VHD_axis_volume_controller_ARCH;
