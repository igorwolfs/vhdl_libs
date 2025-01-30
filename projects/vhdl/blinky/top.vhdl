
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity top is
    Port ( 
    -- STD_LOG: single-bit type.
           btn0 : in STD_LOGIC;
           led0 : out STD_LOGIC
);

end top;

architecture Behavioral of top is
begin

    led0 <= btn0;


end Behavioral;
