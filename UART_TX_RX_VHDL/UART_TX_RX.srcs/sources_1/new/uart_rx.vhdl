----------------------------------------------------------------------
-- File Downloaded from http://www.nandland.com
----------------------------------------------------------------------
-- This file contains the UART Receiver.  This receiver is able to
-- receive 8 bits of serial data, one start bit, one stop bit,
-- and no parity bit.  When receive is complete o_rx_dv will be
-- driven high for one clock cycle.s
-- 
-- Set Generic g_CLKS_PER_BIT as follows:
-- g_CLKS_PER_BIT = (Frequency of i_Clk)/(Frequency of UART)
-- Example: 10 MHz Clock, 115200 baud UART
-- (10000000)/(115200) = 87

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity UART_RX is
    
 
  -- Generic variable: 
  -- - it's a "macro" that you can change to change the baud-rate.
  -- - Set as "integer" so can hold whole numbers.
  -- NOTE: ":=" is an instantaneous assignment, "<=" is an assignment on a clock-edge.

  generic (
    g_CLKS_PER_BIT : integer := 115     -- Needs to be set correctly
    );
  port (
    
    i_Clk       : in  std_logic;
    i_RX_Serial : in  std_logic;
    o_RX_DV     : out std_logic;
    o_RX_Byte   : out std_logic_vector(7 downto 0);
    o_SM_State  : out t_SM_Main
    );
end UART_RX;
 
 
architecture rtl of UART_RX is

-----------------------------------------------------------------------------
  -- *** DECLARATIVE REGION ***
  -- Region where we declare 
  -- * signals * 
  -- Internal signals storing values
  -- Default values are NOT taken into account in HW      
  -- * constants *
  -- Unmodifiable, used to e.g.: set ranges of values
  -- * functions *
  -- Reusable pieces of code.
  -- * types *
  -- Used to define your own datatype in VHDL
  -- e.g.: existing array of datatypes / own datatypes
  -- * subtypes *
  -- Restrict the possible values of a type.
  -- * Variables *
  -- Keep track of values within a context (But don't necessarily represent anything physically)
  -- * Components (declaration) *
  -- To use an entity, make sure to also define the generic declarations. 
  -- These are invisible outside of the architecture
-----------------------------------------------------------------------------

  --  >>> State machine declared here
  type t_SM_Main is (s_Idle, 
                      s_RX_Start_Bit, 
                      s_RX_Data_Bits,
                      s_RX_Stop_Bit, 
                      s_Cleanup);

  signal r_SM_Main : t_SM_Main := s_Idle;

   --  <<< State machine declared here

  signal r_RX_Data_R : std_logic := '0';
  signal r_RX_Data   : std_logic := '0';
   
  signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
  signal r_Bit_Index : integer range 0 to 7 := 0;                       -- 8 Bits Total
  signal r_RX_Byte   : std_logic_vector(7 downto 0) := (others => '0'); -- rx byte, initialized as "00000000"
  signal r_RX_DV     : std_logic := '0';                                -- Indicates cleanup

begin
-----------------------------------------------------------------------------
  -- *** CONCURRENT REGION ***
  -- = area after the begin region
  -- here the behaviour of the design is described using concurrent statements.
  -- - process
  -- - component instantiations
  -- - signal assignments

  -- *** PROCEDURAL BLOCKS ***
  -- * PROCESS *
  -- executes whenever a signal on the sensitivity-list changes. (i_Clk as an example here)

  -- * PROCEDURE *
  -- Reusable block of procedural code with inputs and output values
  -- * FUNCTION *
  -- Reusable block of code returning a single value
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
-- *** P_SAMPLE - USE ***
-- clock edge 1: saves the input into r_RX_Data_R 
-- clock edge 2: store r_RX_Data_R into r_RX_Data.
-- r_RX_Data is then actually used. (so there's always a delay of 1xi_Clk)

-- = use of double-flipflop sync-technique.
-- - r_RX_Data holds the synchronized stable value.
-- Otherwise you might risking transitioning too close to the clock edge, and letting in an asynchronous signal into your state machine.

-- NOTE:
-- 1. The expressions on the right-hand side are evaluated FIRST
-- 2. The assignments however "<=" is performed AT the clock edge.
-- 3. This introduces the delay (since r_RX_Data_R is still its old value when r_RX_Data gets it assigned)
-----------------------------------------------------------------------------
  p_SAMPLE : process (i_Clk)
  begin
    if rising_edge(i_Clk) then
      r_RX_Data_R <= i_RX_Serial;
      r_RX_Data   <= r_RX_Data_R; 
    end if;
  end process p_SAMPLE;
 
  -- Purpose: Control RX state machine
  p_UART_RX : process (i_Clk)
  begin
    if rising_edge(i_Clk) then
      case r_SM_Main is
        -- Always starts idle
        when s_Idle =>
          r_RX_DV     <= '0';
          r_Clk_Count <= 0;
          r_Bit_Index <= 0;
          

          if r_RX_Data = '0' then       
          -- Start bit detected
            r_SM_Main <= s_RX_Start_Bit;
          else
            r_SM_Main <= s_Idle;
          end if;
 
          -- Check middle of start bit to make sure it's still low
          when s_RX_Start_Bit =>
          if r_Clk_Count = (g_CLKS_PER_BIT-1)/2 then
            if r_RX_Data = '0' then
              r_Clk_Count <= 0;  -- reset counter since we found the middle
              r_SM_Main   <= s_RX_Data_Bits;
            else
              r_SM_Main   <= s_Idle;
            end if;
          else
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_RX_Start_Bit;
          end if;
         
        -- Wait g_CLKS_PER_BIT-1 clock cycles to sample serial data
        when s_RX_Data_Bits =>
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_RX_Data_Bits;
          else
            r_Clk_Count            <= 0;
            r_RX_Byte(r_Bit_Index) <= r_RX_Data;
             
            -- Check if we have sent out all bits
            if r_Bit_Index < 7 then
              r_Bit_Index <= r_Bit_Index + 1;
              r_SM_Main   <= s_RX_Data_Bits;
            else
              r_Bit_Index <= 0;
              r_SM_Main   <= s_RX_Stop_Bit;
            end if;
          end if;
           
        -- Receive Stop bit. Stop bit = 1
        when s_RX_Stop_Bit =>
          -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_RX_Stop_Bit;
          else
            r_RX_DV     <= '1';
            r_Clk_Count <= 0;
            r_SM_Main   <= s_Cleanup;
          end if;
            
        -- Stay here 1 clock
        when s_Cleanup =>
          r_SM_Main <= s_Idle;
          r_RX_DV   <= '0'; 
          
        when others =>
          r_SM_Main <= s_Idle;
 
      end case;
    end if;
  end process p_UART_RX;
 
  -- NOTE: outside of the continuous assignment, so will ALWAYS be assigned the register values
  o_RX_DV   <= r_RX_DV;
  o_RX_Byte <= r_RX_Byte;
  o_SM_State <= r_SM_Main;
end rtl;

