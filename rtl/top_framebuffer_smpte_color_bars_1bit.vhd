----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Design Name:
-- Module Name: top_framebuffer_smpte_colorbars_1bit - Behavioral
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



entity top_framebuffer_smpte_colorbars_1bit is
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        o_vga_hsync : out std_logic;
        o_vga_vsync : out std_logic;
        o_vga_r : out std_logic_vector(3 downto 0);
        o_vga_g : out std_logic_vector(3 downto 0);
        o_vga_b : out std_logic_vector(3 downto 0);
        o_locked : out std_logic
    );
end entity top_framebuffer_smpte_colorbars_1bit;

architecture rtl of top_framebuffer_smpte_colorbars_1bit is

    constant COORDINATE_WIDTH : integer := 16;

    -- simple_480p signals
    signal clk_pixel : std_logic;
    signal w_sx : signed(COORDINATE_WIDTH-1 downto 0) := (others => '0');
    signal w_sy : signed(COORDINATE_WIDTH-1 downto 0) := (others => '0');
    signal w_hsync : std_logic := '0';
    signal w_vsync : std_logic := '0';
    signal w_data_en : std_logic := '0';
    signal w_frame : std_logic := '0';
    signal w_line : std_logic := '0';

    -- color parameters
    constant CHANNEL_WIDTH : integer := 4;
    constant COLOR_WIDTH : integer := CHANNEL_WIDTH * 3;
    constant BACKGND_COLOR : std_logic_vector(COLOR_WIDTH-1 downto 0) := x"137";

    -- framebuffer
    constant FB_WIDTH : integer := 640;                     -- frambuffer pixel width
    constant FB_HEIGHT : integer := 480;                    -- frambuffer pixel height
    constant FB_PIXELS : integer := FB_WIDTH * FB_HEIGHT;   -- total framebuffer pixels
    constant FB_ADDR_WIDTH : integer := 19;                 -- address width
    constant FB_DATA_WIDTH : integer := 1;                  -- color bits per pixel

    -- pixel read address and color
    signal w_fb_addr_read : std_logic_vector(FB_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal w_fb_color_read : std_logic_vector(FB_DATA_WIDTH-1 downto 0) := (others => '0');

    -- paint area signals
    constant LAT : integer := 2;
    signal w_fb_read : std_logic := '0';
    signal w_paint_area : std_logic := '0';
    signal w_paint_r : std_logic_vector(CHANNEL_WIDTH - 1 downto 0) := (others => '0');
    signal w_paint_g : std_logic_vector(CHANNEL_WIDTH - 1 downto 0) := (others => '0');
    signal w_paint_b : std_logic_vector(CHANNEL_WIDTH - 1 downto 0) := (others => '0');
    signal w_disp_r : std_logic_vector(CHANNEL_WIDTH - 1 downto 0) := (others => '0');
    signal w_disp_g : std_logic_vector(CHANNEL_WIDTH - 1 downto 0) := (others => '0');
    signal w_disp_b : std_logic_vector(CHANNEL_WIDTH - 1 downto 0) := (others => '0');

begin

    INST_pixel_clk : macro_clk_xlnx
    port map (
        clk_in1 => clk,
        reset => rst_n,
        clk_out1 => clk_pixel,
        locked => o_locked
    );

    -- display sync signals and coordinates
    INST_display_480p : display_480p
    generic map(
        COORDINATE_WIDTH => COORDINATE_WIDTH
    )
    port map(
        i_clk_pixel => clk_pixel,
        i_rst_pixel => rst_n,
        o_sx => w_sx,
        o_sy => w_sy,
        o_hsync => w_hsync,
        o_vsync => w_vsync,
        o_data_en => w_data_en,
        o_frame => w_frame,
        o_line => w_line
    );

    -- calculate framebuffer read address
    process(clk_pixel)
    begin
        if rising_edge(clk_pixel) then
            w_fb_read <= '1' when ((w_sy >= 0 and w_sy < FB_HEIGHT) and (w_sx >= -LAT and w_sx < FB_WIDTH - LAT)) else '0';

            if w_frame = '1' then
                w_fb_addr_read <= (others => '0');
            elsif w_fb_read = '1' then
                w_fb_addr_read <= std_logic_vector(unsigned(w_fb_addr_read) + 1);
            end if;
        end if;
    end process;

    w_paint_area <= '1' when (w_sy >= 0 and w_sy < FB_HEIGHT and w_sx >= 0 and w_sx < FB_WIDTH) else '0';

    -- instantiate framebuffer: vivado BRAM simple dual port read only
    INST_framebuffer : ram_sdp_smpte_colorbars_1bit
    generic map(
        DATA_WIDTH => FB_DATA_WIDTH,
        ADDR_WIDTH => FB_ADDR_WIDTH
    )
    port map(
        clka => clk_pixel,
        i_ena => '0',
        i_wea => '0',
        i_addra => (others => '0'),
        i_dina => (others => '0'),
        clkb => clk_pixel,
        i_enb => w_fb_read,
        i_addrb => w_fb_addr_read,
        o_doutb => w_fb_color_read
    );

    paint_picture : process(w_paint_area)
    begin
        if w_paint_area = '1' then
            w_paint_r <= (others => w_fb_color_read(0));
            w_paint_g <= (others => w_fb_color_read(0));
            w_paint_b <= (others => w_fb_color_read(0));
        else
            w_paint_r <= BACKGND_COLOR(11 downto 8);
            w_paint_g <= BACKGND_COLOR(7 downto 4);
            w_paint_b <= BACKGND_COLOR(3 downto 0);
        end if;
    end process paint_picture;

    -- data enable
    paint_display : process(w_paint_r, w_paint_g, w_paint_b, w_data_en)
    begin
        if w_data_en = '1' then
            w_disp_r <= w_paint_r;
            w_disp_g <= w_paint_g;
            w_disp_b <= w_paint_b;
        else
            w_disp_r <= (others => '0');
            w_disp_g <= (others => '0');
            w_disp_b <= (others => '0');
        end if;
    end process paint_display;

    vga_output : process(clk_pixel)
    begin
        if rising_edge(clk_pixel) then
            o_vga_hsync <= w_hsync;
            o_vga_vsync <= w_vsync;
            o_vga_r <= w_disp_r;
            o_vga_g <= w_disp_g;
            o_vga_b <= w_disp_b;
        end if;
    end process vga_output;

end architecture rtl;

