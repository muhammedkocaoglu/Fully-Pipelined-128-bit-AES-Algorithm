----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/01/2022 01:08:31 AM
-- Design Name: 
-- Module Name: tb_fifo - Behavioral
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

ENTITY tb_fifo IS
    --  Port ( );
END tb_fifo;

ARCHITECTURE Behavioral OF tb_fifo IS

    COMPONENT fifo_generator_0
        PORT (
            clk   : IN STD_LOGIC;
            din   : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout  : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
            full  : OUT STD_LOGIC;
            empty : OUT STD_LOGIC
        );
    END COMPONENT;
    SIGNAL fifo_din   : STD_LOGIC_VECTOR(127 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fifo_wr_en : STD_LOGIC                      := '0';
    SIGNAL fifo_rd_en : STD_LOGIC                      := '0';
    SIGNAL fifo_dout  : STD_LOGIC_VECTOR(127 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fifo_full  : STD_LOGIC;
    SIGNAL fifo_empty : STD_LOGIC;

    SIGNAL CLK : STD_LOGIC := '1';

BEGIN
    CLK <= NOT CLK AFTER 5 ns;

    dut : process 
    begin
        wait for 50 ns;
        wait until falling_edge(CLK);
        fifo_wr_en   <= '1';
        fifo_din     <= x"2b7e151628aed2a6abf7158809cf4f3c";
        wait until falling_edge(CLK);
        fifo_din     <= x"2b7e151628aed2a6abf7158809cf4123";
        wait until falling_edge(CLK);
        fifo_din     <= x"2b7e151628aed2a6abf7158809cf4acd";
        wait until falling_edge(CLK);
        fifo_din     <= x"2b7e151628aed2a6abf7158809cf4aaa";
        wait until falling_edge(CLK);
        fifo_din     <= x"2b7e151628aed2a6abf7158809cf4bbb";
        wait until falling_edge(CLK);
        fifo_din     <= x"2b7e151628aed2a6abf7158809cf4ccc";
        wait until falling_edge(CLK);
        fifo_wr_en   <= '0';
        wait for 50 ns;


        wait until falling_edge(CLK);
        fifo_rd_en  <= '1';
        wait until falling_edge(CLK);
        wait until falling_edge(CLK);
        wait until falling_edge(CLK);
        wait until falling_edge(CLK);
        wait for 50 ns;
        std.env.finish;
    end process;

    your_instance_name : fifo_generator_0
    PORT MAP(
        clk   => CLK,
        din   => fifo_din,
        wr_en => fifo_wr_en,
        rd_en => fifo_rd_en,
        dout  => fifo_dout,
        full  => fifo_full,
        empty => fifo_empty
    );
END Behavioral;