library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mixcolumnOneByte is
    port (
        i1       : in std_logic_vector (7 downto 0);
        i2       : in std_logic_vector (7 downto 0);
        i3       : in std_logic_vector (7 downto 0);
        i4       : in std_logic_vector (7 downto 0);
        data_out : out std_logic_vector (7 downto 0)
    );
end mixcolumnOneByte;

architecture Behavioral of mixcolumnOneByte is

begin
    data_out(7) <= i1(6) xor i2(6) xor i2(7) xor i3(7) xor i4(7);
    data_out(6) <= i1(5) xor i2(5) xor i2(6) xor i3(6) xor i4(6);
    data_out(5) <= i1(4) xor i2(4) xor i2(5) xor i3(5) xor i4(5);
    data_out(4) <= i1(3) xor i1(7) xor i2(3) xor i2(4) xor i2(7) xor i3(4) xor i4(4);
    data_out(3) <= i1(2) xor i1(7) xor i2(2) xor i2(3) xor i2(7) xor i3(3) xor i4(3);
    data_out(2) <= i1(1) xor i2(1) xor i2(2) xor i3(2) xor i4(2);
    data_out(1) <= i1(0) xor i1(7) xor i2(0) xor i2(1) xor i2(7) xor i3(1) xor i4(1);
    data_out(0) <= i1(7) xor i2(7) xor i2(0) xor i3(0) xor i4(0);
end Behavioral;