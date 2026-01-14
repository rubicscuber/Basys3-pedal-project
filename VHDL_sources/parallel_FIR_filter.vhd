--| |-----------------------------------------------------------| |
--| |-----------------------------------------------------------| |
--| |       _______           __      __      __          __    | |
--| |     /|   __  \        /|  |   /|  |   /|  \        /  |   | |
--| |    / |  |  \  \      / |  |  / |  |  / |   \      /   |   | |
--| |   |  |  |\  \  \    |  |  | |  |  | |  |    \    /    |   | |
--| |   |  |  | \  \  \   |  |  | |  |  | |  |     \  /     |   | |
--| |   |  |  |  \  \  \  |  |  |_|__|  | |  |      \/      |   | |
--| |   |  |  |   \  \  \ |  |          | |  |  |\      /|  |   | |
--| |   |  |  |   /  /  / |  |   ____   | |  |  | \    / |  |   | |
--| |   |  |  |  /  /  /  |  |  |__/ |  | |  |  |\ \  /| |  |   | |
--| |   |  |  | /  /  /   |  |  | |  |  | |  |  | \ \//| |  |   | |
--| |   |  |  |/  /  /    |  |  | |  |  | |  |  |  \|/ | |  |   | |
--| |   |  |  |__/  /     |  |  | |  |  | |  |  |      | |  |   | |
--| |   |  |_______/      |  |__| |  |__| |  |__|      | |__|   | |
--| |   |_/_______/       |_/__/  |_/__/  |_/__/       |_/__/   | |
--| |                                                           | |
--| |-----------------------------------------------------------| |
--| |=============-Developed by Dimitar H.Marinov-==============| |
--|_|-----------------------------------------------------------|_|

--IP: Parallel FIR Filter
--Version: V1 - Standalone 
--Fuctionality: Generic FIR filter
--IO Description
--  clk     : system clock = sampling clock
--  reset   : resets the M registes (buffers) and the P registers (delay line) of the DSP48 blocks 
--  enable  : acts as bypass switch - bypass(0), active(1) 
--  data_i  : data input (signed)
--  data_o  : data output (signed)
--
--Generics Description
--  FILTER_TAPS  : Specifies the amount of filter taps (multiplications)
--  INPUT_WIDTH  : Specifies the input width (8-25 bits)
--  COEFF_WIDTH  : Specifies the coefficient width (8-18 bits)
--  OUTPUT_WIDTH : Specifies the output width (8-43 bits)
--
--Finished on: 30.06.2019
--Notes: the DSP attribute is required to make use of the DSP slices efficiently
--------------------------------------------------------------------
--================= https://github.com/DHMarinov =================--
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity parallel_FIR_filter is

    generic(
        FILTER_TAPS  : integer               := 60;
        INPUT_WIDTH  : integer range 8 to 25 := 12;
        COEFF_WIDTH  : integer range 8 to 18 := 12;
        OUTPUT_WIDTH : integer range 8 to 43 := 12 -- This should be < (Input+Coeff width-1) 
    );

    port(
        clock        : in  STD_LOGIC;
        reset        : in  STD_LOGIC;

        s_axi_data_i : in  STD_LOGIC_VECTOR(INPUT_WIDTH - 1 downto 0);
        s_axi_valid_i  : in  std_logic;
        s_axi_ready_o  : out std_logic;

        m_axi_data_o : out STD_LOGIC_VECTOR(OUTPUT_WIDTH - 1 downto 0);
        m_axi_valid_o  : out std_logic;
        m_axi_ready_i  : in  std_logic
    );
end parallel_FIR_filter;

architecture behavioral of parallel_FIR_filter is

    attribute use_dsp               : string;
    attribute use_dsp of Behavioral : architecture is "yes";

    constant MAC_WIDTH : integer := COEFF_WIDTH + INPUT_WIDTH; --32 = 16 + 16

    type   input_registers is array (0 to FILTER_TAPS - 1) of signed(INPUT_WIDTH - 1 downto 0);
    signal areg_s          : input_registers := (others => (others => '0'));

    type   mult_registers is array (0 to FILTER_TAPS - 1) of signed(INPUT_WIDTH + COEFF_WIDTH - 1 downto 0);
    signal mreg_s         : mult_registers := (others => (others => '0'));

    type   dsp_registers is array (0 to FILTER_TAPS - 1) of signed(MAC_WIDTH - 1 downto 0);
    signal preg_s        : dsp_registers := (others => (others => '0'));

    signal dout_s : std_logic_vector(MAC_WIDTH - 1 downto 0);
    signal sign_s : signed(MAC_WIDTH - INPUT_WIDTH - COEFF_WIDTH + 1 downto 0) := (others => '0');

    -- Chebyshev 1kH LPF, causes overflow at low freq. 
    type   coefficients is array (0 to 59) of signed(12-1 downto 0);
    signal breg_s       : coefficients := (
        -- 500Hz Blackman LPF
        x"000", x"001", x"005", x"00C",
        x"016", x"025", x"037", x"04E",
        x"069", x"08B", x"0B2", x"0E0",
        x"114", x"14E", x"18E", x"1D3",
        x"21D", x"26A", x"2BA", x"30B",
        x"35B", x"3AA", x"3F5", x"43B",
        x"47B", x"4B2", x"4E0", x"504",
        x"51C", x"528", x"528", x"51C",
        x"504", x"4E0", x"4B2", x"47B",
        x"43B", x"3F5", x"3AA", x"35B",
        x"30B", x"2BA", x"26A", x"21D",
        x"1D3", x"18E", x"14E", x"114",
        x"0E0", x"0B2", x"08B", x"069",
        x"04E", x"037", x"025", x"016",
        x"00C", x"005", x"001", x"000");

        constant ACTIVE : std_logic := '1';
        signal s_axi_ready_out_s : std_logic;
        signal m_axi_valid_out_s : std_logic;
begin

    s_axi_ready_o <= s_axi_ready_out_s;
    m_axi_valid_o <= m_axi_valid_out_s;

    --TODO: stopping point: fix logic that will go on axi master side
    
    axi_slave : process(clock) is 
    begin
        if rising_edge(clock) then
            if reset = '1' then
            s_axi_ready_out_s <= '1';
            else
                if s_axi_valid_i = '1' and s_axi_ready_out_s = '1' then
                    s_axi_ready_out_s <= '0'; 
                elsif s_axi_ready_out_s = '0' then
                    s_axi_ready_out_s <= '1';
                end if;
            end if;
        end if;
    end process;

    axi_master : process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                m_axi_data_o <= (others => '0');
                m_axi_valid_out_s <= '0';
            else
                if m_axi_ready_i = '1' then
                    m_axi_data_o <= std_logic_vector(preg_s(0)(MAC_WIDTH - 2 downto MAC_WIDTH - OUTPUT_WIDTH - 1));
                    m_axi_valid_out_s <= '1';
                elsif m_axi_valid_out_s = '1' then 
                    m_axi_valid_out_s <= '0';
                end if;
            end if;
        end if;
    end process;

    --32-2 downto 32-16-1
    --30 downto 15 so this filter is not passing the MSB to output why?
    --m_axi_data_o <= std_logic_vector(preg_s(0)(MAC_WIDTH - 2 downto MAC_WIDTH - OUTPUT_WIDTH - 1));

    PARALLEL_FIR : process(clock) is
    begin
        if rising_edge(clock) then

            if (reset = ACTIVE) then
                for i in 0 to FILTER_TAPS - 1 loop
                    areg_s(i) <= (others => '0');
                    mreg_s(i) <= (others => '0');
                    preg_s(i) <= (others => '0');
                end loop;

            elsif (reset = not ACTIVE) then
                if s_axi_valid_i = ACTIVE and s_axi_ready_out_s = ACTIVE then
                    for i in 0 to FILTER_TAPS - 1 loop
                        areg_s(i) <= signed(s_axi_data_i);

                        if (i < FILTER_TAPS - 1) then
                            mreg_s(i) <= areg_s(i) * breg_s(i);
                            preg_s(i) <= mreg_s(i) + preg_s(i + 1);

                        elsif (i = FILTER_TAPS - 1) then
                            mreg_s(i) <= areg_s(i) * breg_s(i);
                            preg_s(i) <= mreg_s(i);
                        end if;
                    end loop;
                end if;
            end if;
        end if;
    end process;

end behavioral;
