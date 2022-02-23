----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/30/2021 11:10:22 PM
-- Design Name: 
-- Module Name: tb_mixcolumnOneByte - Behavioral
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
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY tb_mixcolumnOneByte IS
    --  Port ( );
END tb_mixcolumnOneByte;

ARCHITECTURE Behavioral OF tb_mixcolumnOneByte IS

    COMPONENT mixcolumnOneByte IS
        PORT (
            i1       : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            i2       : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            i3       : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            i4       : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
    END COMPONENT;
    signal i1       : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal i2       : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal i3       : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal i4       : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal data_out : STD_LOGIC_VECTOR (7 DOWNTO 0);

BEGIN


dut : process  
begin
    wait for 50 ns;
    i1  <= X"D4";
    i2  <= X"BF";
    i3  <= X"5D";
    i4  <= X"30";
    wait for 50 ns;
    i1  <= X"bf";
    i2  <= X"5d";
    i3  <= X"30";
    i4  <= X"d4";
    wait for 50 ns;
    i1  <= X"5d";
    i2  <= X"30";
    i3  <= X"d4";
    i4  <= X"bf";
    wait for 50 ns;
    i1  <= X"30";
    i2  <= X"D4";
    i3  <= X"BF";
    i4  <= X"5D";
    wait for 50 ns;
    
    std.env.finish;
end process;



mixcolumnOneByte_Inst : mixcolumnOneByte 
PORT map (
    i1       => i1,
    i2       => i2,
    i3       => i3,
    i4       => i4,
    data_out => data_out
);
END Behavioral;