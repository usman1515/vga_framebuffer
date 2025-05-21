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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.rtl_components.all;


entity display_480p is
    generic (
        COORDINATE_WIDTH : integer := 16        -- signed coordinate width (bits)
    );
    port (
        i_clk_pixel : in std_logic;             -- pixel clk
        i_rst_pixel : in std_logic;             -- reset in pixel clk
        o_sx        : out signed(COORDINATE_WIDTH-1 downto 0);   -- horizontal screen position
        o_sy        : out signed(COORDINATE_WIDTH-1 downto 0);   -- vertical screen position
        o_hsync     : out std_logic;            -- horizontal sync
        o_vsync     : out std_logic;            -- vertical sync
        o_data_en   : out std_logic;            -- data enable (low in blanking interval)
        o_frame     : out std_logic;            -- high at start of frame
        o_line      : out std_logic             -- high at start of line
    );
end display_480p;

architecture Behavioral of display_480p is

    -- horizontal and vertical timings
    constant H_ACTIVE_PIX   : integer := 640;
    constant H_FRONT_PORCH  : integer := 16;
    constant H_SYNC_WIDTH   : integer := 96;
    constant H_BACK_PORCH   : integer := 48;
    constant H_POLARITY     : integer := 0;

    constant V_ACTIVE_PIX   : integer := 480;
    constant V_FRONT_PORCH  : integer := 10;
    constant V_SYNC_WIDTH   : integer := 2;
    constant V_BACK_PORCH   : integer := 33;
    constant V_POLARITY     : integer := 0;

    constant H_START        : integer := 0 - H_FRONT_PORCH - H_SYNC_WIDTH - H_BACK_PORCH;
    constant H_SYNC_START   : integer := H_START + H_FRONT_PORCH;
    constant H_SYNC_END     : integer := H_SYNC_START + H_SYNC_WIDTH;
    constant H_ACTUAL_START : integer := 0;
    constant H_ACTUAL_END   : integer := H_ACTIVE_PIX - 1;

    constant V_START        : integer := 0 - V_FRONT_PORCH - V_SYNC_WIDTH - V_BACK_PORCH;
    constant V_SYNC_START   : integer := V_START + V_FRONT_PORCH;
    constant V_SYNC_END     : integer := V_SYNC_START + V_SYNC_WIDTH;
    constant V_ACTUAL_START : integer := 0;
    constant V_ACTUAL_END   : integer := V_ACTIVE_PIX - 1;

    signal w_sx : signed(COORDINATE_WIDTH-1 downto 0);
    signal w_sy : signed(COORDINATE_WIDTH-1 downto 0);

begin

    process(i_clk_pixel)
    begin
        if rising_edge(i_clk_pixel) then
            -- Sync signal generation
            if i_rst_pixel = '1' then
                o_hsync <= std_logic(to_unsigned(1 - H_POLARITY, 1)(0));
                o_vsync <= std_logic(to_unsigned(1 - V_POLARITY, 1)(0));
            else
                if (w_sx >= to_signed(H_SYNC_START, COORDINATE_WIDTH) and w_sx < to_signed(H_SYNC_END, COORDINATE_WIDTH)) then
                    o_hsync <= std_logic(to_unsigned(H_POLARITY, 1)(0));
                else
                    o_hsync <= std_logic(to_unsigned(1 - H_POLARITY, 1)(0));
                end if;

                if (w_sy >= to_signed(V_SYNC_START, COORDINATE_WIDTH) and w_sy < to_signed(V_SYNC_END, COORDINATE_WIDTH)) then
                    o_vsync <= std_logic(to_unsigned(V_POLARITY, 1)(0));
                else
                    o_vsync <= std_logic(to_unsigned(1 - V_POLARITY, 1)(0));
                end if;
            end if;
        end if;
    end process;

    -- Control signal logic
    process(i_clk_pixel)
    begin
        if rising_edge(i_clk_pixel) then
            if i_rst_pixel = '1' then
                o_data_en <= '0';
                o_frame <= '0';
                o_line <= '0';
            else
                o_data_en <= '1' when (w_sy >= to_signed(V_ACTUAL_START, COORDINATE_WIDTH) and w_sx >= to_signed(H_ACTUAL_START, COORDINATE_WIDTH)) else '0';
                o_frame <= '1' when (w_sy = to_signed(V_START, COORDINATE_WIDTH) and w_sx = to_signed(H_START, COORDINATE_WIDTH)) else '0';
                o_line <= '1' when (w_sx = to_signed(H_START, COORDINATE_WIDTH)) else '0';
            end if;
        end if;
    end process;

    -- Coordinate generation
    process(i_clk_pixel)
    begin
        if rising_edge(i_clk_pixel) then
            if i_rst_pixel = '1' then
                w_sx <= to_signed(H_START, COORDINATE_WIDTH);
                w_sy <= to_signed(V_START, COORDINATE_WIDTH);
            else
                if w_sx = to_signed(H_ACTUAL_END, COORDINATE_WIDTH) then
                    w_sx <= to_signed(H_START, COORDINATE_WIDTH);
                    if w_sy = to_signed(V_ACTUAL_END, COORDINATE_WIDTH) then
                        w_sy <= to_signed(V_START, COORDINATE_WIDTH);
                    else
                        w_sy <= w_sy + 1;
                    end if;
                else
                    w_sx <= w_sx + 1;
                end if;
            end if;
        end if;
    end process;

    -- Delay position signals
    process(i_clk_pixel)
    begin
        if rising_edge(i_clk_pixel) then
            if i_rst_pixel = '1' then
                o_sx <= to_signed(H_START, COORDINATE_WIDTH);
                o_sy <= to_signed(V_START, COORDINATE_WIDTH);
            else
                o_sx <= w_sx;
                o_sy <= w_sy;
            end if;
        end if;
    end process;

end Behavioral;

