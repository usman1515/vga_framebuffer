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

    component top_color_gradient_vga is
        port (
            clk : in std_logic;
            rst_n : in std_logic;
            o_vga_hsync : out std_logic;
            o_vga_vsync : out std_logic;
            o_vga_r : out std_logic_vector(3 downto 0);
            o_vga_g : out std_logic_vector(3 downto 0);
            o_vga_b : out std_logic_vector(3 downto 0)
        );
    end component top_color_gradient_vga;

    component display_480p is
        generic (
            COORDINATE_WIDTH : integer
        );
        port (
            i_clk_pixel : in std_logic;
            i_rst_pixel : in std_logic;
            o_sx        : out signed(COORDINATE_WIDTH-1 downto 0);
            o_sy        : out signed(COORDINATE_WIDTH-1 downto 0);
            o_hsync     : out std_logic;
            o_vsync     : out std_logic;
            o_data_en   : out std_logic;
            o_frame     : out std_logic;
            o_line      : out std_logic
        );
    end component display_480p;

    component macro_bram_sdp_david_monochrome_1bit is
        port (
            clka : in std_logic;
            ena : in std_logic;
            wea : in std_logic_vector(0 downto 0);
            addra : in std_logic_vector(14 downto 0);
            dina : in std_logic_vector(0 downto 0);
            clkb : in std_logic;
            enb : in std_logic;
            addrb : in std_logic_vector(14 downto 0);
            doutb : out std_logic_vector(0 downto 0)
        );
    end component macro_bram_sdp_david_monochrome_1bit;

    component macro_bram_sdp_monalisa_monochrome_1bit is
        port (
            clka : in std_logic;
            ena : in std_logic;
            wea : in std_logic_vector(0 downto 0);
            addra : in std_logic_vector(17 downto 0);
            dina : in std_logic_vector(7 downto 0);
            clkb : in std_logic;
            enb : in std_logic;
            addrb : in std_logic_vector(17 downto 0);
            doutb : out std_logic_vector(7 downto 0)
        );
    end component macro_bram_sdp_monalisa_monochrome_1bit;

    component clut_grayscale is
        port (
            i_index : in std_logic_vector(3 downto 0);
            o_color : out std_logic_vector(11 downto 0)
        );
    end component clut_grayscale;

    component clut_color is
        port (
            i_index : in std_logic_vector(3 downto 0);
            o_color : out std_logic_vector(11 downto 0)
        );
    end component clut_color;

    component ram_sdp_smpte_colorbars_monochrome is
        generic (
            DATA_WIDTH : integer;
            ADDR_WIDTH : integer
        );
        port (
            clka : in std_logic;
            i_ena : in std_logic;
            i_wea : in std_logic;
            i_addra : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            i_dina : in std_logic_vector(DATA_WIDTH-1 downto 0);
            clkb : in std_logic;
            i_enb : in std_logic;
            i_addrb : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            o_doutb : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component ram_sdp_smpte_colorbars_monochrome;

    component ram_sdp_smpte_colorbars_grayscale is
        generic (
            DATA_WIDTH : integer;
            ADDR_WIDTH : integer
        );
        port (
            clka : in std_logic;
            i_ena : in std_logic;
            i_wea : in std_logic;
            i_addra : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            i_dina : in std_logic_vector(DATA_WIDTH-1 downto 0);
            clkb : in std_logic;
            i_enb : in std_logic;
            i_addrb : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            o_doutb : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component ram_sdp_smpte_colorbars_grayscale;

    component ram_sdp_smpte_colorbars_tty16 is
        generic (
            DATA_WIDTH : integer;
            ADDR_WIDTH : integer
        );
        port (
            clka : in std_logic;
            i_ena : in std_logic;
            i_wea : in std_logic;
            i_addra : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            i_dina : in std_logic_vector(DATA_WIDTH-1 downto 0);
            clkb : in std_logic;
            i_enb : in std_logic;
            i_addrb : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            o_doutb : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component ram_sdp_smpte_colorbars_tty16;

    component ram_sdp_phillips_pm5544_monochrome is
        generic (
            DATA_WIDTH : integer;
            ADDR_WIDTH : integer
        );
        port (
            clka : in std_logic;
            i_ena : in std_logic;
            i_wea : in std_logic;
            i_addra : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            i_dina : in std_logic_vector(DATA_WIDTH-1 downto 0);
            clkb : in std_logic;
            i_enb : in std_logic;
            i_addrb : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            o_doutb : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component ram_sdp_phillips_pm5544_monochrome;

    component ram_sdp_phillips_pm5544_grayscale is
        generic (
            DATA_WIDTH : integer;
            ADDR_WIDTH : integer
        );
        port (
            clka : in std_logic;
            i_ena : in std_logic;
            i_wea : in std_logic;
            i_addra : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            i_dina : in std_logic_vector(DATA_WIDTH-1 downto 0);
            clkb : in std_logic;
            i_enb : in std_logic;
            i_addrb : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            o_doutb : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component ram_sdp_phillips_pm5544_grayscale;

end package rtl_components;

