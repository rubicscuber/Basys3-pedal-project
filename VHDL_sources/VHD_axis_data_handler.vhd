library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
----------------------------------------------------------------------------
-- The this component is intended for use in tandem with 
-- the Block ROM component nr_rom.vhd
--
-- As of the latest version of this design, the Block ROM (nr_rom)
-- recieves a std_logic_vector of the top 16 bits from the 
-- ADC in a signed form and asserts the cooresponding output
-- on the very next clock cycle. 
--
-- The data in this component will be passed to the output
-- as soon at the s_new_packet flag shifts to r_new_packet
-- on the very next clock cycle (assuming the ready is also asserted)
-- This means that the ROM has only one clock cycle to hand back valid data.
----------------------------------------------------------------------------
entity VHD_axis_data_handler is
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
end entity VHD_axis_data_handler;

architecture VHD_axis_volume_controller_ARCH of VHD_axis_data_handler is

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
    --constant DATA_FILE : string := "tanh_16x65536.mif";
    --constant DATA_FILE : string := "9tanh_16x65536.mif";
    constant DATA_FILE : string := "20tanh_16x65536.mif";
    --constant DATA_FILE : string := "tanh_24x.16777216.mif";

    signal addr : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal dout : std_logic_vector(DATA_WIDTH-1 downto 0);

    --type data_array is array (integer range <>) of std_logic_vector(31 downto 0);
    --signal data : data_array(0 to 1);

    signal s_new_packet : std_logic;
    signal s_new_packet_r : std_logic;
    signal m_new_packet : std_logic;
    signal m_axis_valid_out : std_logic;
    signal s_axis_ready_out : std_logic;

    --constant vecotr of zeros to fill the least significant of output data
    constant ZEROS : std_logic_vector(31-BIT_WIDTH_G downto 0) := (others => '0');

    signal s_addr : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal signed_addr_int : integer;

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

    --strip the top 16 bits of the 32 bit vector
    s_addr <= s_axis_data_in(31 downto (31-DATA_WIDTH+1)); 

    --convert the signed vector to integer such that it ranges from 0 to 65,536
    signed_addr_int <= to_integer(signed(s_addr)) + 2**DATA_WIDTH/2; 

    NEW_PACKET_IN : process(clock) is
    begin
        if rising_edge(clock) then
            if s_axis_valid = '1' and s_axis_ready_out = '1' then
                s_new_packet <= '1';

                addr <= std_logic_vector(to_unsigned(signed_addr_int, BIT_WIDTH_G));

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
    --this process is essentially giving the Block ROM 
    --one clock cycle to turn around and hand back valid 
    --data without asking any questions.
    S_NEW_PACKET_SHIFT : process(clock) is
    begin
        if rising_edge(clock) then
            s_new_packet_r <= s_new_packet;
        end if;
    end process;

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

                m_axis_data_out <= dout & ZEROS;

            elsif m_new_packet = '1' then
                m_axis_valid_out <= '0';
            end if;
        end if;
    end process;

    m_axis_valid <= m_axis_valid_out;

end architecture VHD_axis_volume_controller_ARCH;
