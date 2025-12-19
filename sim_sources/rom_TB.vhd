library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_TB is
end entity rom_TB;

architecture behavioral of rom_TB is

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

    --constant DATA_WIDTH : integer := 24;
    --constant ADDR_WIDTH : integer := 24;
    --constant DATA_FILE : string := "tanh_24x16777216.mif"; --data_width x number_of_addresses

    constant DATA_WIDTH : integer := 12;
    constant ADDR_WIDTH : integer := 12;
    constant DATA_FILE : string := "tanh_12x4096.mif";

    --constant DATA_WIDTH : integer := 12;
    --constant ADDR_WIDTH : integer := 12;
    --constant DATA_FILE : string := "tanh_12x4096.mif";

    signal clock : std_logic;
    signal reset : std_logic;
    signal addr : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal dout : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    UUT: nr_rom
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

    reset_proc : process is
    begin
        reset <= '0';
        wait for 1 ns;
        reset <= '1';
        wait;
    end process;

    clock_gen : process is
    begin
        clock <= '0';
        wait for 1 ns;
        clock <= '1';
        wait for 1 ns;
    end process;

    stim : process is 
    begin
        --signed range of the input data that will address the LUT
        --for 12 bit (4096 possible adresses) the signed_range= -2048 to 2047
        testLoop: for i in (-1)*(2**ADDR_WIDTH)/2 to (2**ADDR_WIDTH)/2-1 loop
            wait until rising_edge(clock);
            addr <= std_logic_vector(to_signed(i, ADDR_WIDTH));
        end loop testLoop;
        wait;
    end process;

end architecture behavioral;
