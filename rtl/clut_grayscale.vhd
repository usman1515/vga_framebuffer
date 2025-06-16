----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Design Name:
-- Module Name: clut_grayscale - Behavioral
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



entity clut_grayscale is
    port (
        i_index : in std_logic_vector(3 downto 0);
        o_color : out std_logic_vector(11 downto 0)
    );
end entity clut_grayscale;

architecture rtl of clut_grayscale is

begin

    color_grayscale : process(i_index)
    begin
        case i_index is
            when x"0" => o_color <= x"000"; -- Black (R=0, G=0, B=0)
            when x"1" => o_color <= x"111"; -- Very Dark Gray
            when x"2" => o_color <= x"222"; -- Dark Gray
            when x"3" => o_color <= x"333"; -- Gray
            when x"4" => o_color <= x"444"; -- Medium Gray
            when x"5" => o_color <= x"555"; -- Light Gray
            when x"6" => o_color <= x"666"; -- Lighter Gray
            when x"7" => o_color <= x"777"; -- Pale Gray
            when x"8" => o_color <= x"888"; -- Very Pale Gray
            when x"9" => o_color <= x"999"; -- Near White
            when x"a" => o_color <= x"AAA"; -- Soft White
            when x"b" => o_color <= x"BBB"; -- Dim White
            when x"c" => o_color <= x"CCC"; -- White-ish
            when x"d" => o_color <= x"DDD"; -- Almost White
            when x"e" => o_color <= x"EEE"; -- Very Near White
            when x"f" => o_color <= x"FFF"; -- Pure White (R=15, G=15, B=15)
            when others => o_color <= x"000"; -- Default to Black
        end case;
    end process color_grayscale ;

end architecture rtl;

