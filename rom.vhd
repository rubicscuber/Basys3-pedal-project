library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

entity rom is
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
end entity rom;

architecture rom_arch of rom is
    type mem_type is array (0 to (2**ADDR_WIDTH_G-1)) of std_logic_vector(DATA_WIDTH_G-1 downto 0);

    signal dout_reg1 : std_logic_vector(DATA_WIDTH_G-1 downto 0);
    signal dout_reg2 : std_logic_vector(DATA_WIDTH_G-1 downto 0);

    impure function InitRomFromFile (FileName : in string) return mem_type is
        FILE RomFile : text open READ_MODE is FileName;
        variable RomFileLine : line;
        variable ROM : mem_type;
        variable temp_data : bit_vector(DATA_WIDTH_G-1 downto 0);
        
    begin
        for i in mem_type'range loop
            readline (RomFile, RomFileLine); 
            read(RomFileLine, temp_data);
            ROM(i) := to_stdlogicvector(temp_data);
        end loop;

        return ROM;
    end function;

    signal memory : mem_type := InitRomFromFile(DATA_FILE_G);

begin

    READ_MEMORY : process(clock) is 
    begin
        if rising_edge(clock) then
            dout_reg1 <= memory(conv_integer(addr));
            dout_reg2 <= dout_reg1;
        end if;
    end process;

    REGISTER_OUTPUT : process(clock) is
    begin
        if rising_edge(clock) then
            dout <= dout_reg2;
            --dout <= dout_reg1; --optional, may use generic to swap between behaviors
        end if;
    end process;

end architecture rom_arch;
