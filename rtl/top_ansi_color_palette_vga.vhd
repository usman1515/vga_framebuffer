----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Design Name:
-- Module Name: top_ansi_color_palette_vga - Behavioral
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



entity top_ansi_color_palette_vga is
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        o_vga_hsync : out std_logic;
        o_vga_vsync : out std_logic;
        o_vga_r : out std_logic_vector(3 downto 0);
        o_vga_g : out std_logic_vector(3 downto 0);
        o_vga_b : out std_logic_vector(3 downto 0)
    );
end entity top_ansi_color_palette_vga;

architecture rtl of top_ansi_color_palette_vga is

    -- simple_480p signals
    signal clk_pixel : std_logic;
    signal w_sx : std_logic_vector(9 downto 0) := (others => '0');
    signal w_sy : std_logic_vector(9 downto 0) := (others => '0');
    signal w_hsync : std_logic := '0';
    signal w_vsync : std_logic := '0';
    signal w_data_en : std_logic := '0';

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
        locked => open
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

    -- paint bright colors
    paint_colors : process(all)
    begin
        if (unsigned(w_sy) >= 0 and unsigned(w_sy) < 30) then       -- red
            w_paint_r <= x"8";
            w_paint_g <= x"0";
            w_paint_b <= x"0";
        elsif (unsigned(w_sy) >= 30 and unsigned(w_sy) < 60) then   -- green
            w_paint_r <= x"0";
            w_paint_g <= x"8";
            w_paint_b <= x"0";
        elsif (unsigned(w_sy) >= 60 and unsigned(w_sy) < 90) then   -- yellow
            w_paint_r <= x"8";
            w_paint_g <= x"8";
            w_paint_b <= x"0";
        elsif (unsigned(w_sy) >= 90 and unsigned(w_sy) < 120) then  -- blue
            w_paint_r <= x"0";
            w_paint_g <= x"0";
            w_paint_b <= x"8";
        elsif (unsigned(w_sy) >= 120 and unsigned(w_sy) < 150) then -- magenta
            w_paint_r <= x"8";
            w_paint_g <= x"0";
            w_paint_b <= x"8";
        elsif (unsigned(w_sy) >= 150 and unsigned(w_sy) < 180) then -- cyan
            w_paint_r <= x"0";
            w_paint_g <= x"8";
            w_paint_b <= x"8";
        elsif (unsigned(w_sy) >= 180 and unsigned(w_sy) < 210) then -- light gray
            w_paint_r <= x"b";
            w_paint_g <= x"b";
            w_paint_b <= x"b";
        elsif (unsigned(w_sy) >= 210 and unsigned(w_sy) < 240) then -- bright gray
            w_paint_r <= x"8";
            w_paint_g <= x"8";
            w_paint_b <= x"8";
        elsif (unsigned(w_sy) >= 240 and unsigned(w_sy) < 270) then -- bright red
            w_paint_r <= x"f";
            w_paint_g <= x"0";
            w_paint_b <= x"0";
        elsif (unsigned(w_sy) >= 270 and unsigned(w_sy) < 300) then -- bright green
            w_paint_r <= x"0";
            w_paint_g <= x"f";
            w_paint_b <= x"0";
        elsif (unsigned(w_sy) >= 300 and unsigned(w_sy) < 330) then -- bright yellow
            w_paint_r <= x"f";
            w_paint_g <= x"f";
            w_paint_b <= x"0";
        elsif (unsigned(w_sy) >= 330 and unsigned(w_sy) < 360) then -- bright blue
            w_paint_r <= x"0";
            w_paint_g <= x"0";
            w_paint_b <= x"f";
        elsif (unsigned(w_sy) >= 360 and unsigned(w_sy) < 390) then -- bright magenta
            w_paint_r <= x"f";
            w_paint_g <= x"0";
            w_paint_b <= x"f";
        elsif (unsigned(w_sy) >= 390 and unsigned(w_sy) < 420) then -- bright cyan
            w_paint_r <= x"0";
            w_paint_g <= x"f";
            w_paint_b <= x"f";
        elsif (unsigned(w_sy) >= 420 and unsigned(w_sy) < 450) then -- white
            w_paint_r <= x"f";
            w_paint_g <= x"f";
            w_paint_b <= x"f";
        else                                                        -- black
            w_paint_r <= x"0";
            w_paint_g <= x"0";
            w_paint_b <= x"0";
        end if;
    end process paint_colors;

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

