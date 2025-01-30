----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/25/2025 01:46:11 PM
-- Design Name: 
-- Module Name: pwm - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pwm is
    Port 
    ( 
    -- Output vector of logic elments
    led : out STD_LOGIC_VECTOR (3 downto 0);
    clk : in STD_LOGIC
    );
end pwm;

architecture Behavioral of pwm is
-- "others" refers to all elements of a vector array. So others => 0 means all bits of the counter array are set to 0
    signal counter : unsigned(7 downto 0) := (others => '0'); -- 8-bit counter

    -- Duty cycle thresholds (10%, 20%, 30%, 40%)
    constant DUTY_1 : integer := 10;  -- 10% 
    constant DUTY_2 : integer := 20;  -- 20% 
    constant DUTY_3 : integer := 30; -- 30% 
    constant DUTY_4 : integer := 40; -- 40% 
begin    
    -- Process: whenever "clk" changes, in here describe the effect of a rising / falling clock edge
    process(clk)
    begin
        if rising_edge(clk) then
            if counter = 100 then
                counter <= (others => '0');
            else
                counter <= counter + 1; -- Increment counter
            end if;
        end if;
    end process;
    
    -- '0' is used to indicate a logic-low for single-bit values, "" is used to represent multi-bit values (e.g.: "00000000" for 8-bit.
    led(0) <= '1' when (counter < DUTY_1) else '0';
    led(1) <= '1' when (counter < DUTY_2) else '0';
    led(2) <= '1' when (counter < DUTY_3) else '0';
    led(3) <= '1' when (counter < DUTY_4) else '0';

end Behavioral;
