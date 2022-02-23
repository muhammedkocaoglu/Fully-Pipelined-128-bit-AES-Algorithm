----------------------------------------------------------------------------------
-- Company: 
-- Engineer: MUHAMMED KOCAOGLU
-- 
-- Create Date: 12/29/2021 12:01:25 AM
-- Design Name: 
-- Module Name: AES_Encrypt - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use work.AES_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AES_Encrypt is
    port (
        CLK         : in std_logic;
        aes_enable  : in std_logic;
        aes_stop    : in std_logic;
        aes_key     : in std_logic_vector(16 * 8 - 1 downto 0);
        aes_message : in std_logic_vector(16 * 8 - 1 downto 0);
        aes_out     : out std_logic_vector(16 * 8 - 1 downto 0);
        aes_done    : out std_logic;
        aes_valid   : out std_logic
    );
end AES_Encrypt;

architecture Behavioral of AES_Encrypt is
    signal aes_matrix : array3D8;

    type subkeyArray is array (natural range 0 to 9) of array3D8;
    signal subkeys          : subkeyArray;
    signal cipheredMessages : subkeyArray;

    signal cntr      : integer range 0 to 15 := 0;
    signal cntrValid : integer range 0 to 15 := 0;

    signal aes_stop_Reg : std_logic := '0';
    type states is (
        S_IDLE,
        S_CIPHER
    );
    signal state : states := S_IDLE;

begin
    P_MAIN : process (CLK)
    begin
        if rising_edge(CLK) then
            aes_done <= '0';
            case state is
                when S_IDLE =>
                    aes_stop_Reg <= '0';
                    aes_valid    <= '0';
                    if aes_enable = '1' then
                        state <= S_CIPHER;
                    end if;

                when S_CIPHER =>
                    if aes_stop = '1' then
                        aes_stop_Reg <= '1';
                    end if;

                    if aes_stop_Reg = '1' then
                        if cntr < 10 then
                            cntr <= cntr + 1;
                        else
                            aes_valid    <= '0';
                            cntr         <= 0;
                            cntrValid    <= 0;
                            aes_done     <= '1';
                            aes_stop_Reg <= '0';
                            state        <= S_IDLE;
                        end if;
                    end if;

                    if cntrValid = 10 then
                        aes_valid <= '1';
                    else
                        cntrValid <= cntrValid + 1;
                    end if;

                    subkeys(0)          <= generateSubKey(aes_key, 0);
                    cipheredMessages(0) <= encryptMessage(aes_message, aes_key);
                    for i in 0 to 8 loop
                        subkeys(i + 1)          <= generateSubKey(subkeys(i), i + 1);
                        cipheredMessages(i + 1) <= encryptMessage(cipheredMessages(i), subkeys(i));
                    end loop;
                    aes_out <= encyrptFinal(cipheredMessages(9), subkeys(9));

            end case;

        end if;
    end process;
end Behavioral;