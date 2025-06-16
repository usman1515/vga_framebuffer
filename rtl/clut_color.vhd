----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Design Name:
-- Module Name: clut_color - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions: 2021.2
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.rtl_components.all;



entity clut_color is
    port (
        i_index : in std_logic_vector(3 downto 0);
        o_color : out std_logic_vector(11 downto 0)
    );
end entity clut_color;

architecture rtl of clut_color is

begin

    color_tty : process(i_index)
    begin
        case i_index is
            when x"0"  => o_color <= x"000"; -- Black
            when x"1"  => o_color <= x"800"; -- Red
            when x"2"  => o_color <= x"080"; -- Green
            when x"3"  => o_color <= x"880"; -- Brown/Yellow
            when x"4"  => o_color <= x"008"; -- Blue
            when x"5"  => o_color <= x"808"; -- Magenta
            when x"6"  => o_color <= x"088"; -- Cyan
            when x"7"  => o_color <= x"888"; -- Light Gray
            when x"8"  => o_color <= x"444"; -- Dark Gray
            when x"9"  => o_color <= x"F00"; -- Bright Red
            when x"A"  => o_color <= x"0F0"; -- Bright Green
            when x"B"  => o_color <= x"FF0"; -- Bright Yellow
            when x"C"  => o_color <= x"00F"; -- Bright Blue
            when x"D"  => o_color <= x"F0F"; -- Bright Magenta
            when x"E"  => o_color <= x"0FF"; -- Bright Cyan
            when x"F"  => o_color <= x"FFF"; -- White
            when others => o_color <= x"000"; -- Default Black
        end case;
    end process color_tty;

end architecture rtl;

