library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VHD_axis_volume_controller is
    generic(BIT_WIDTH_G : integer := 16);
    port(
        clock : in std_logic;
        reset : in std_logic;

        s_axis_data_in : in std_logic_vector(31 downto 0);
        s_axis_valid : in std_logic;
        s_axis_ready : out std_logic;

        m_axis_data_out : out std_logic_vector(31 downto 0);
        m_axis_valid : out std_logic;
        m_axis_ready : in std_logic
    );
end entity VHD_axis_volume_controller;

architecture VHD_axis_volume_controller_ARCH of VHD_axis_volume_controller is

    component nr_rom
        generic(
            DATA_WIDTH_G : integer;
            ADDR_WIDTH_G : integer;
            DATA_FILE_G  : string
        );
        port(
            clock : in  std_logic;
            reset : in  std_logic;
            addr  : in  std_logic_vector;
            dout  : out std_logic_vector
        );
    end component nr_rom;

    constant DATA_WIDTH : integer := BIT_WIDTH_G;
    constant ADDR_WIDTH : integer := BIT_WIDTH_G;
    --constant DATA_FILE : string := "tanh_12x4096.mif";
    constant DATA_FILE : string := "tanh_16x65536.mif";
    --constant DATA_FILE : string := "tanh_24x.16777216.mif";

    signal addr : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal dout : std_logic_vector(DATA_WIDTH-1 downto 0);

    type data_array is array (integer range <>) of std_logic_vector(31 downto 0);
    --signal data : data_array(0 to 1);

    signal s_new_packet : std_logic;
    signal s_new_packet_r : std_logic;
    signal m_new_packet : std_logic;
    signal m_axis_valid_out : std_logic;
    signal s_axis_ready_out : std_logic;

    --range (7 downto 0) for concatenation
    constant ZEROS : std_logic_vector(31-BIT_WIDTH_G downto 0) := (others => '0');

begin

    rom_inst: component nr_rom
        generic map(
            DATA_WIDTH_G => DATA_WIDTH,
            ADDR_WIDTH_G => ADDR_WIDTH,
            DATA_FILE_G  => DATA_FILE 
        )
        port map(
            clock => clock,
            reset => reset,
            addr  => addr,
            dout  => dout
        );
    

    s_axis_ready <= s_axis_ready_out;
    
    --C-style logic for the new_packet flag, purley combinational
    --wire s_new_word = (s_axis_valid == 1'b1 && s_axis_ready == 1'b1) ? 1'b1 : 1'b0;
    --wire s_new_packet = (s_new_word == 1'b1 && s_axis_last == 1'b1) ? 1'b1 : 1'b0;

    NEW_PACKET_IN : process(clock) is
    begin
        if rising_edge(clock) then
            if s_axis_valid = '1' and s_axis_ready_out = '1' then
                s_new_packet <= '1';
                --data(0) <= s_axis_data_in;

                --access adress in rom component take top cut of the incoming data vector
                --31-24+1=8 for top 24 bits
                --31-16+1=16 for top 16 bits
                addr <= s_axis_data_in(31 downto (31-DATA_WIDTH+1)); 

            else 
                s_new_packet <= '0';
            end if;
        end if;
    end process;

    S_READY_OUT : process(clock, reset) 
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

    --wire m_new_word = (m_axis_valid == 1'b1 && m_axis_ready == 1'b1) ? 1'b1 : 1'b0;
    --wire m_new_packet = (m_new_word == 1'b1 && m_axis_last == 1'b1) ? 1'b1 : 1'b0;

    NEW_PACKET_OUT : process(clock) is
    begin
        if rising_edge(clock) then
            if m_axis_valid_out = '1' and m_axis_ready = '1' then
                m_new_packet <= '1';
            else 
                m_new_packet <= '0';
            end if;
        end if;
    end process;

    M_VALID_OUT : process(clock, reset)
    begin
        if reset = '1' then
            m_axis_valid_out <= '0';
            m_axis_data_out <= (others => '0');

        elsif rising_edge(clock) then
            if s_new_packet_r = '1' then
                m_axis_valid_out <= '1';
                --m_axis_data_out <= data(0);

                --dout is width 24, zeros is width 8
                m_axis_data_out <= dout & ZEROS;

            elsif m_new_packet = '1' then
                m_axis_valid_out <= '0';
            end if;
        end if;
    end process;

    --M_LAST_OUT : process(clock, reset)
    --begin
    --    if reset = '1' then
    --        m_axis_last_out <= '0';
    --    elsif rising_edge(clock) then
    --        if m_new_packet = '1' then
    --            m_axis_last_out <= '0';
    --        elsif m_new_word = '1' then
    --            m_axis_last_out <= '1';
    --        end if;
    --    end if;
    --end process;

    m_axis_valid <= m_axis_valid_out;

    --TRANSMIT_DATA : process(clock)
    --begin
    --    if rising_edge(clock) then
    --        if m_axis_valid_out = '1' then
    --            m_axis_data_out <= data(0);
    --        else
    --            m_axis_data_out <= (others => '0');
    --        end if;
    --    end if;
    --end process;

    

end architecture VHD_axis_volume_controller_ARCH;
