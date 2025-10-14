library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

--
-- Read only memory designed to take addresses directly from ADC data
-- ADC data is expected to span the signed range 
--
--
entity nr_rom is
    generic(
        DATA_WIDTH_G : integer;
        ADDR_WIDTH_G : integer;
        DATA_FILE_G : string 
    );
    port(
        clock : in std_logic;
        reset : in std_logic;

        addr : in std_logic_vector;
        dout : out std_logic_vector
    );
end entity nr_rom;

architecture behavioral of nr_rom is
    type mem_type is array (0 to (2**ADDR_WIDTH_G-1)) of std_logic_vector(DATA_WIDTH_G-1 downto 0);

    signal dout_reg1 : std_logic_vector(DATA_WIDTH_G-1 downto 0);
    signal dout_reg2 : std_logic_vector(DATA_WIDTH_G-1 downto 0);

    impure function InitRomFromFile (FileName : in string) return mem_type is
        FILE RomFile : text open READ_MODE is FileName;
        variable RomFileLine : line;
        variable ROM_MEMORY : mem_type;
        variable temp_data : bit_vector(DATA_WIDTH_G-1 downto 0);
        
    begin
        for i in mem_type'range loop
            readline (RomFile, RomFileLine); 
            read(RomFileLine, temp_data);
            ROM_MEMORY(i) := to_stdlogicvector(temp_data);
        end loop;

        return ROM_MEMORY;
    end function;

    constant memory : mem_type := InitRomFromFile(DATA_FILE_G);

begin

    READ_MEMORY : process(clock) is 
    begin
        if rising_edge(clock) then
            --dout_reg1 <= memory(to_integer(signed(addr)) + 2048);
            --dout_reg2 <= dout_reg1;

            --take input up from the negative rage
            --TODO: move this functionality to the i2s2 component
            dout <= memory(to_integer(signed(addr)) + 2**ADDR_WIDTH_G/2 );
        end if;
    end process;

    --REGISTER_OUTPUT : process(clock) is
    --begin
    --    if rising_edge(clock) then
    --        --dout <= dout_reg2;
    --        dout <= dout_reg1; --optional, may use generic to swap between behaviors
    --    end if;
    --end process;

end architecture behavioral;
