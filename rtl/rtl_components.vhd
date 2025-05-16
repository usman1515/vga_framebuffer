----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Design Name:
-- Module Name: rtl_components - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;
library UNIMACRO;
use UNIMACRO.vcomponents.all;



package rtl_components is

    component macro_clk_xlnx is
        port (
            clk_in1 : in std_logic;
            reset : in std_logic;
            clk_out1 : out std_logic;
            locked : out std_logic
        );
    end component macro_clk_xlnx;

    component simple_vga is
        port (
            i_clk_pixel : in std_logic;
            i_rst_pixel : in std_logic;
            o_sx        : out std_logic_vector(9 downto 0);
            o_sy        : out std_logic_vector(9 downto 0);
            o_hsync     : out std_logic;
            o_vsync     : out std_logic;
            o_data_en   : out std_logic
        );
    end component simple_vga;

    component top_square_vga is
        port (
            clk : in std_logic;
            rst_n : in std_logic;
            o_vga_hsync : out std_logic;
            o_vga_vsync : out std_logic;
            o_vga_r : out std_logic_vector(3 downto 0);
            o_vga_g : out std_logic_vector(3 downto 0);
            o_vga_b : out std_logic_vector(3 downto 0)
        );
    end component top_square_vga;

    component top_ansi_color_palette_vga is
        port (
            clk : in std_logic;
            rst_n : in std_logic;
            o_vga_hsync : out std_logic;
            o_vga_vsync : out std_logic;
            o_vga_r : out std_logic_vector(3 downto 0);
            o_vga_g : out std_logic_vector(3 downto 0);
            o_vga_b : out std_logic_vector(3 downto 0)
        );
    end component top_ansi_color_palette_vga;

end package rtl_components;

