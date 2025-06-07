----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Design Name:
-- Module Name: ram_sdp_smpte_colorbars_monochrome - Behavioral
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
use work.ram_init_smpte_color_bars_monochrome.all;


entity ram_sdp_smpte_colorbars_monochrome is
    generic (
        DATA_WIDTH : integer := 1;  --4;
        ADDR_WIDTH : integer := 19
    );
    port (
        -- port A
        clka : in std_logic;
        i_ena : in std_logic;
        i_wea : in std_logic;
        i_addra : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        i_dina : in std_logic_vector(DATA_WIDTH-1 downto 0);

        -- port B
        clkb : in std_logic;
        i_enb : in std_logic;
        i_addrb : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        o_doutb : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity ram_sdp_smpte_colorbars_monochrome;

architecture rtl of ram_sdp_smpte_colorbars_monochrome is

    constant DEPTH : integer := 640*480;
    subtype addr_t is integer range 0 to DEPTH - 1;

    signal w_doutb : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- INFO: https://docs.amd.com/r/en-US/ug912-vivado-properties/RAM_STYLE
    attribute ram_style : string;

    -- memory block
    signal ram : ram_type := INIT_RAM;
    attribute ram_style of ram : signal is "block";

begin

    -- Write Port (Port A)
    process(clka)
    begin
        if rising_edge(clka) then
            if i_ena = '1' then
                if i_wea = '1' then
                    ram(to_integer(unsigned(i_addra))) <= i_dina;
                end if;
            end if;
        end if;
    end process;

    -- Read Port (Port B)
    process(clkb)
    begin
        if rising_edge(clkb) then
            if i_enb = '1' then
                w_doutb <= ram(to_integer(unsigned(i_addrb)));
            end if;
        end if;
    end process;

    o_doutb <= w_doutb;

end architecture;
