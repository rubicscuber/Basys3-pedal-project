library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VHD_axis_volume_controller is
    port(
        clock : in std_logic;
        reset : in std_logic;

        s_axis_data_in : in std_logic_vector(31 downto 0);
        s_axis_valid : in std_logic;
        s_axis_ready : out std_logic;
        s_axis_last : in std_logic; 

        m_axis_data_out : out std_logic_vector(31 downto 0);
        m_axis_valid : out std_logic;
        m_axis_ready : in std_logic;
        m_axis_last : out std_logic
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
    signal m_axis_valid_out : std_logic;
    signal m_axis_last_out : std_logic;
    signal s_axis_ready_out : std_logic;

begin

    s_axis_ready <= s_axis_ready_out;
    
    --C-style logic for the new_packet flag, purley combinational
    --wire s_new_word = (s_axis_valid == 1'b1 && s_axis_ready == 1'b1) ? 1'b1 : 1'b0;
    --wire s_new_packet = (s_new_word == 1'b1 && s_axis_last == 1'b1) ? 1'b1 : 1'b0;

    S_NEW_WORD_PACKET : process(clock) is
    begin
        if rising_edge(clock) then
            if s_axis_valid = '1' and s_axis_ready_out = '1' and s_axis_last = '1' then
                s_new_packet <= '1';
                data(0) <= s_axis_data_in;
            else 
                s_new_packet <= '0';
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
        --if rising_edge(clock) then
        --    if s_new_packet = '1' then
        --        data(0) <= s_axis_data_in & "00000000";
        --    end if;
        --end if;
    end process;

    m_axis_last <= m_axis_last_out;

    --wire m_new_word = (m_axis_valid == 1'b1 && m_axis_ready == 1'b1) ? 1'b1 : 1'b0;
    --wire m_new_packet = (m_new_word == 1'b1 && m_axis_last == 1'b1) ? 1'b1 : 1'b0;

    M_NEW_WORD_PACKET : process(clock) is
    begin
        if rising_edge(clock) then
            if m_axis_valid_out = '1' and m_axis_ready = '1' and m_axis_last_out = '1' then
                m_new_packet <= '1';
            else 
                m_new_packet <= '0';
            end if;
        end if;
    end process;

    --TODO: valid should assert after receiving ready and *math was completed
    M_AXIS_VALID_PROC : process(clock)
    begin
        if rising_edge(clock) then
            if s_new_packet_r = '1' then
                m_axis_valid_out <= '1';
            elsif m_new_packet = '1' then
                m_axis_valid_out <= '0';
            end if;
        end if;
    end process;

    --TODO: rework axis logic to remove last
    M_AXIS_LAST_PROC : process(clock, reset)
    begin
        if reset = '1' then
            m_axis_last_out <= '0';
        elsif rising_edge(clock) then
            if m_new_packet = '1' then
                m_axis_last_out <= '0';
            elsif m_new_word = '1' then
                m_axis_last_out <= '1';
            end if;
        end if;
    end process;

    m_axis_valid <= m_axis_valid_out;

    TRANSMIT_DATA : process(clock)
    begin
        if rising_edge(clock) then
            if m_axis_valid_out = '1' then
                m_axis_data_out <= data(0);
            else
                m_axis_data_out <= (others => '0');
            end if;
        end if;
    end process;

    S_AXIS_READY_PROC : process(clock, reset) 
    begin
        if reset = '1' then
            s_axis_ready_out <= '1';
        elsif rising_edge(clock) then
            if s_new_packet = '1' then
                s_axis_ready_out <= '0';
            elsif m_new_packet = '1' then
                s_axis_ready_out <= '1';
            end if;
        end if;
    end process;

end architecture VHD_axis_volume_controller_ARCH;
