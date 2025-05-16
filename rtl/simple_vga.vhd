----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Design Name:
-- Module Name: simple_vga - Behavioral
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



entity simple_vga is
    port (
        i_clk_pixel : in std_logic;     -- pixel clk
        i_rst_pixel : in std_logic;     -- reset in pixel clk
        o_sx        : out std_logic_vector(9 downto 0);     -- horizontal screen position
        o_sy        : out std_logic_vector(9 downto 0);     -- vertical screen position
        o_hsync     : out std_logic;    -- horizontal sync
        o_vsync     : out std_logic;    -- vertical sync
        o_data_en   : out std_logic     -- data enable (low in blanking interval)
    );
end entity simple_vga;

architecture rtl of simple_vga is

    -- horizontal and vertical timings - 640x480
    constant H_ACTIVE_PIX   : natural := 640 - 1;
    constant H_FRONT_PORCH  : natural := 16;
    constant H_SYNC_WIDTH   : natural := 96;
    constant H_BACK_PORCH   : natural := 48;
    constant V_ACTIVE_PIX   : natural := 480 - 1;
    constant V_FRONT_PORCH  : natural := 10;
    constant V_SYNC_WIDTH   : natural := 2;
    constant V_BACK_PORCH   : natural := 33;


    constant H_SYNC_START   : natural := H_ACTIVE_PIX + H_FRONT_PORCH;
    constant H_SYNC_END     : natural := H_ACTIVE_PIX + H_FRONT_PORCH + H_SYNC_WIDTH;
    constant H_LINE : natural := H_BACK_PORCH + H_ACTIVE_PIX + H_FRONT_PORCH + H_SYNC_WIDTH;

    constant V_SYNC_START   : natural := V_ACTIVE_PIX + V_FRONT_PORCH;
    constant V_SYNC_END     : natural := V_ACTIVE_PIX + V_FRONT_PORCH + V_SYNC_WIDTH;
    constant V_SCREEN : natural := V_BACK_PORCH + V_ACTIVE_PIX + V_FRONT_PORCH + V_SYNC_WIDTH;

begin

    -- sync polarity is negative
    o_hsync <= '0' when (to_integer(unsigned(o_sx)) >= H_SYNC_START and to_integer(unsigned(o_sx)) < H_SYNC_END) else '1';
    o_vsync <= '0' when (to_integer(unsigned(o_sy)) >= V_SYNC_START and to_integer(unsigned(o_sy)) < V_SYNC_END) else '1';
    o_data_en <= '1' when (to_integer(unsigned(o_sx)) <= H_ACTIVE_PIX and to_integer(unsigned(o_sy)) <= V_ACTIVE_PIX) else '0';

    screen_pos : process(i_clk_pixel)
    begin
        if rising_edge(i_clk_pixel) then
            if i_rst_pixel = '1' then
                o_sx <= (others => '0');
                o_sy <= (others => '0');
            else
                if (unsigned(o_sx) = H_LINE) then
                    o_sx <= (others => '0');
                    if unsigned(o_sy) = V_SCREEN then
                        o_sy <= (others => '0');
                    else
                        o_sy <= std_logic_vector(unsigned(o_sy) + 1);
                    end if;
                else
                    o_sx <= std_logic_vector(unsigned(o_sx) + 1);
                end if;
            end if;
        end if;
    end process screen_pos ;

end architecture rtl;

