library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VHD_axis_volume_controller is
    port(
        clock : in std_logic;
        reset : in std_logic;

        s_axis_data : in std_logic_vector(23 downto 0);
        s_axis_valid : in std_logic;
        s_axis_ready : out std_logic;
        s_axis_last : in std_logic;

        m_axis_data : out std_logic_vector(23 downto 0);
        m_axis_valid : out std_logic;
        m_axis_ready : in std_logic;
        m_axis_last : out std_logic
    );
end entity VHD_axis_volume_controller;

architecture VHD_axis_volume_controller_ARCH of VHD_axis_volume_controller is
    type data_register is array (1 downto 0) of std_logic_vector(47 downto 0);
    
    signal data : data_register;
    signal multiplier : 
begin
    
end architecture VHD_axis_volume_controller_ARCH;
