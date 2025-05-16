----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Design Name:
-- Module Name: macro_clk_xlnx - Behavioral
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

library UNISIM;
use UNISIM.vcomponents.all;
library UNIMACRO;
use UNIMACRO.vcomponents.all;

library work;
use work.rtl_components.all;



entity macro_clk_xlnx is
    port (
        clk_in1 : in std_logic;
        reset : in std_logic;
        clk_out1 : out std_logic;
        locked : out std_logic
    );
end entity macro_clk_xlnx;

architecture rtl of macro_clk_xlnx is

    signal w_ref_clk : std_logic := '0';
    signal w_clkout0 : std_logic := '0';
    signal w_clkfbin : std_logic := '0';
    signal w_clkfbout : std_logic := '0';

begin

    INST_inclk : IBUF
    generic map(
        IOSTANDARD => "DEFAULT"
    )
    port map (
        I => clk_in1,
        O => w_ref_clk
    );

    INST_clkfb : BUFG
    port map (
        I => w_clkfbout,
        O => w_clkfbin
    );

    INST_outclk : BUFG
    port map (
        I => w_clkout0,
        O => clk_out1
    );

    mmcm_adv_inst : MMCME2_ADV
    generic map(
        BANDWIDTH => "OPTIMIZED",
        CLKFBOUT_MULT_F => 9.125000,
        CLKFBOUT_PHASE => 0.000000,
        CLKFBOUT_USE_FINE_PS => false,
        CLKIN1_PERIOD => 10.000000,
        CLKIN2_PERIOD => 0.000000,
        CLKOUT0_DIVIDE_F => 36.500000,
        CLKOUT0_DUTY_CYCLE => 0.500000,
        CLKOUT0_PHASE => 0.000000,
        CLKOUT0_USE_FINE_PS => false,
        CLKOUT1_DIVIDE => 1,
        CLKOUT1_DUTY_CYCLE => 0.500000,
        CLKOUT1_PHASE => 0.000000,
        CLKOUT1_USE_FINE_PS => false,
        CLKOUT2_DIVIDE => 1,
        CLKOUT2_DUTY_CYCLE => 0.500000,
        CLKOUT2_PHASE => 0.000000,
        CLKOUT2_USE_FINE_PS => false,
        CLKOUT3_DIVIDE => 1,
        CLKOUT3_DUTY_CYCLE => 0.500000,
        CLKOUT3_PHASE => 0.000000,
        CLKOUT3_USE_FINE_PS => false,
        CLKOUT4_CASCADE => false,
        CLKOUT4_DIVIDE => 1,
        CLKOUT4_DUTY_CYCLE => 0.500000,
        CLKOUT4_PHASE => 0.000000,
        CLKOUT4_USE_FINE_PS => false,
        CLKOUT5_DIVIDE => 1,
        CLKOUT5_DUTY_CYCLE => 0.500000,
        CLKOUT5_PHASE => 0.000000,
        CLKOUT5_USE_FINE_PS => false,
        CLKOUT6_DIVIDE => 1,
        CLKOUT6_DUTY_CYCLE => 0.500000,
        CLKOUT6_PHASE => 0.000000,
        CLKOUT6_USE_FINE_PS => false,
        COMPENSATION => "ZHOLD",
        DIVCLK_DIVIDE => 1,
        IS_CLKINSEL_INVERTED => '0',
        IS_PSEN_INVERTED => '0',
        IS_PSINCDEC_INVERTED => '0',
        IS_PWRDWN_INVERTED => '0',
        IS_RST_INVERTED => '0',
        REF_JITTER1 => 0.010000,
        REF_JITTER2 => 0.010000,
        SS_EN => "FALSE",
        SS_MODE => "CENTER_HIGH",
        SS_MOD_PERIOD => 10000,
        STARTUP_WAIT => false
    )
    port map (
        CLKFBIN => w_clkfbin,
        CLKFBOUT => w_clkfbout,
        CLKFBOUTB => open,
        CLKFBSTOPPED => open,
        CLKIN1 => w_ref_clk,
        CLKIN2 => '0',
        CLKINSEL => '1',
        CLKINSTOPPED => open,
        CLKOUT0 => w_clkout0,
        CLKOUT0B => open,
        CLKOUT1 => open,
        CLKOUT1B => open,
        CLKOUT2 => open,
        CLKOUT2B => open,
        CLKOUT3 => open,
        CLKOUT3B => open,
        CLKOUT4 => open,
        CLKOUT5 => open,
        CLKOUT6 => open,
        DADDR(6 downto 0) => b"0000000",
        DCLK => '0',
        DEN => '0',
        DI(15 downto 0) => x"0000",
        DO(15 downto 0) => open,
        DRDY => open,
        DWE => '0',
        LOCKED => locked,
        PSCLK => '0',
        PSDONE => open,
        PSEN => '0',
        PSINCDEC => '0',
        PWRDWN => '0',
        RST => reset
    );

end architecture rtl;

