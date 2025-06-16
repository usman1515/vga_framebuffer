----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Design Name:
-- Module Name: top_square_vga - Behavioral
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



entity top_square_vga is
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        o_locked : out std_logic;
        o_vga_hsync : out std_logic;
        o_vga_vsync : out std_logic;
        o_vga_r : out std_logic_vector(3 downto 0);
        o_vga_g : out std_logic_vector(3 downto 0);
        o_vga_b : out std_logic_vector(3 downto 0)
    );
end entity top_square_vga;

architecture rtl of top_square_vga is

    -- simple_480p signals
    signal clk_pixel : std_logic;
    signal w_sx : std_logic_vector(9 downto 0) := (others => '0');
    signal w_sy : std_logic_vector(9 downto 0) := (others => '0');
    signal w_hsync : std_logic := '0';
    signal w_vsync : std_logic := '0';
    signal w_data_en : std_logic := '0';

    -- vga signals
    signal w_square : std_logic := '0';
    signal w_paint_r : std_logic_vector(3 downto 0) := (others => '0');
    signal w_paint_g : std_logic_vector(3 downto 0) := (others => '0');
    signal w_paint_b : std_logic_vector(3 downto 0) := (others => '0');
    signal w_display_r : std_logic_vector(3 downto 0) := (others => '0');
    signal w_display_g : std_logic_vector(3 downto 0) := (others => '0');
    signal w_display_b : std_logic_vector(3 downto 0) := (others => '0');

begin

    INST_pixel_clk : macro_clk_xlnx
    port map (
        clk_in1 => clk,
        reset => rst_n,
        clk_out1 => clk_pixel,
        locked => o_locked
    );

    INST_simple_vga : simple_vga
    port map(
        i_clk_pixel => clk_pixel,
        i_rst_pixel => rst_n,
        o_sx => w_sx,
        o_sy => w_sy,
        o_hsync => w_hsync,
        o_vsync => w_vsync,
        o_data_en => w_data_en
    );

    -- display square
    w_square <= '1' when ((unsigned(w_sx) > 160 and unsigned(w_sx) < 480) and (unsigned(w_sy) > 120 and unsigned(w_sy) < 340)) else '0';

    -- paint color - white inside and blue outside
    paint_color : process(all)
    begin
        w_paint_r <= x"f" when (w_square = '1') else x"1";
        w_paint_g <= x"f" when (w_square = '1') else x"3";
        w_paint_b <= x"f" when (w_square = '1') else x"7";
    end process paint_color;

    -- display colour - paint colour but black in blanking interval
    display_color : process(all)
    begin
        w_display_r <= w_paint_r when (w_data_en = '1') else (others => '0');
        w_display_g <= w_paint_g when (w_data_en = '1') else (others => '0');
        w_display_b <= w_paint_b when (w_data_en = '1') else (others => '0');
    end process display_color;

    -- vga output
    vga_display : process(clk_pixel)
    begin
        if rising_edge(clk_pixel) then
            o_vga_vsync <= w_vsync;
            o_vga_hsync <= w_hsync;
            o_vga_r <= w_display_r;
            o_vga_g <= w_display_g;
            o_vga_b <= w_display_b;
        end if;
    end process vga_display;

end architecture rtl;

