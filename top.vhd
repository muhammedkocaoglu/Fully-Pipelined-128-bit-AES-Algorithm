----------------------------------------------------------------------------------
-- Company: 
-- Engineer: MUHAMMED KOCAOĞLU
-- 
-- Create Date: 01/01/2022 12:30:53 AM
-- Design Name: 
-- Module Name: top - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    generic (
        c_clkfreq  : integer := 100_000_000;
        c_baudrate : integer := 1e6;
        c_stopbit  : integer := 2
    );
    port (
        CLK  : in std_logic;
        RX_i : in std_logic;
        TX_o : out std_logic
    );
end top;

architecture Behavioral of top is

    component AES_Encrypt is
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
    end component;

    signal aes_enable  : std_logic                             := '0';
    signal aes_stop    : std_logic                             := '0';
    signal aes_key     : std_logic_vector(16 * 8 - 1 downto 0) := (others => '0');
    signal aes_message : std_logic_vector(16 * 8 - 1 downto 0) := (others => '0');
    signal aes_out     : std_logic_vector(16 * 8 - 1 downto 0) := (others => '0');
    signal aes_done    : std_logic                             := '0';
    signal aes_valid   : std_logic                             := '0';

    -- instantiated as IP
    component fifo_generator_0
        port (
            clk   : in std_logic;
            din   : in std_logic_vector(127 downto 0);
            wr_en : in std_logic;
            rd_en : in std_logic;
            dout  : out std_logic_vector(127 downto 0);
            full  : out std_logic;
            empty : out std_logic
        );
    end component;
    signal fifo_din     : std_logic_vector(127 downto 0) := (others => '0');
    signal fifo_din_Reg : std_logic_vector(127 downto 0) := (others => '0');
    signal fifo_wr_en   : std_logic                      := '0';
    signal fifo_rd_en   : std_logic                      := '0';
    signal fifo_dout    : std_logic_vector(127 downto 0) := (others => '0');
    signal fifo_doutReg : std_logic_vector(127 downto 0) := (others => '0');
    signal fifo_full    : std_logic                      := '0';
    signal fifo_empty   : std_logic                      := '0';

    signal fifo_encrypt_din     : std_logic_vector(127 downto 0) := (others => '0');
    signal fifo_encrypt_din_Reg : std_logic_vector(127 downto 0) := (others => '0');
    signal fifo_encrypt_wr_en   : std_logic                      := '0';
    signal fifo_encrypt_rd_en   : std_logic                      := '0';
    signal fifo_encrypt_dout    : std_logic_vector(127 downto 0) := (others => '0');
    signal fifo_encrypt_doutReg : std_logic_vector(127 downto 0) := (others => '0');
    signal fifo_encrypt_full    : std_logic                      := '0';
    signal fifo_encrypt_empty   : std_logic                      := '0';

    component uart_rx is
        generic (
            c_clkfreq  : integer := 100_000_000;
            c_baudrate : integer := 115_200
        );
        port (
            clk            : in std_logic;
            rx_i           : in std_logic;
            dout_o         : out std_logic_vector (7 downto 0);
            rx_done_tick_o : out std_logic
        );
    end component;
    signal dout_o         : std_logic_vector (7 downto 0);
    signal rx_done_tick_o : std_logic := '0';

    component uart_tx is
        generic (
            c_clkfreq  : integer := 100_000_000;
            c_baudrate : integer := 115_200;
            c_stopbit  : integer := 2
        );
        port (
            clk            : in std_logic;
            din_i          : in std_logic_vector (7 downto 0);
            tx_start_i     : in std_logic;
            tx_o           : out std_logic;
            tx_done_tick_o : out std_logic
        );
    end component;
    signal din_i          : std_logic_vector (7 downto 0) := (others => '0');
    signal tx_start_i     : std_logic                     := '0';
    signal tx_done_tick_o : std_logic                     := '0';

    type states is (
        S_IDLE,
        S_ENCRYPT,
        S_TRANSMIT
    );
    signal state : states  := S_IDLE;
    signal cntr  : integer := 0;

begin
    fifo_din <= fifo_din_Reg;
    P_MAIN : process (CLK)
    begin
        if rising_edge(CLK) then
            fifo_wr_en <= '0';

            case state is
                when S_IDLE =>
                    aes_stop   <= '0';
                    aes_enable <= '0';
                    if fifo_full = '0' then
                        if cntr < 16 then
                            if rx_done_tick_o = '1' then
                                fifo_din_Reg <= fifo_din_Reg(15 * 8 - 1 downto 0) & dout_o; -- shift left
                                cntr         <= cntr + 1;
                            end if;
                        else
                            fifo_wr_en <= '1';
                            cntr       <= 0;
                        end if;
                    else
                        state        <= S_ENCRYPT;
                        fifo_din_Reg <= (others => '0');
                        cntr         <= 0;
                    end if;

                when S_ENCRYPT =>
                    --fifo_rd_en <= '0';

                    if cntr = 0 then
                        fifo_rd_en <= '1';
                        cntr       <= cntr + 1;
                    elsif cntr = 1 then
                        cntr        <= cntr + 1;
                        aes_enable  <= '1';
                        aes_message <= fifo_dout;
                        aes_key     <= x"2b7e151628aed2a6abf7158809cf4f3c";
                    elsif cntr = 2 then
                        if fifo_empty = '0' then
                            aes_message <= fifo_dout;
                        else
                            aes_stop   <= '1';
                            fifo_rd_en <= '0';
                        end if;
                        if aes_valid = '1' then
                            fifo_encrypt_wr_en <= '1';
                            fifo_encrypt_din   <= aes_out;
                        end if;
                        if aes_done = '1' then
                            state              <= S_TRANSMIT;
                            fifo_encrypt_wr_en <= '0';
                            cntr               <= 0;
                        end if;
                    end if;

                when S_TRANSMIT =>
                    fifo_encrypt_rd_en <= '0';
                    if cntr = 0 then
                        fifo_encrypt_rd_en <= '1';
                        cntr               <= cntr + 1;
                    elsif cntr = 1 then
                        cntr <= cntr + 1;
                    elsif cntr = 2 then
                        fifo_encrypt_doutReg <= fifo_encrypt_dout;
                        cntr                 <= cntr + 1;
                    elsif cntr = 3 then
                        tx_start_i           <= '1';
                        cntr                 <= cntr + 1;
                        din_i                <= fifo_encrypt_doutReg(16 * 8 - 1 downto 15 * 8);
                        fifo_encrypt_doutReg <= fifo_encrypt_doutReg(15 * 8 - 1 downto 0 * 8) & x"00";
                    elsif cntr < 19 then
                        din_i <= fifo_encrypt_doutReg(16 * 8 - 1 downto 15 * 8);
                        if tx_done_tick_o = '1' then
                            cntr                 <= cntr + 1;
                            fifo_encrypt_doutReg <= fifo_encrypt_doutReg(15 * 8 - 1 downto 0 * 8) & x"00";
                        end if;
                    elsif cntr = 19 then
                        tx_start_i <= '0';
                        if tx_done_tick_o = '1' then
                            if fifo_encrypt_empty = '0' then
                                cntr <= 0;
                            else
                                state                <= S_IDLE;
                                fifo_encrypt_doutReg <= (others => '0');
                                cntr                 <= 0;
                            end if;
                        end if;
                    end if;
            end case;
        end if;
    end process;

    your_instance_name : fifo_generator_0
    port map(
        clk   => CLK,
        din   => fifo_din,
        wr_en => fifo_wr_en,
        rd_en => fifo_rd_en,
        dout  => fifo_dout,
        full  => fifo_full,
        empty => fifo_empty
    );

    fifo_encrypted : fifo_generator_0
    port map(
        clk   => CLK,
        din   => fifo_encrypt_din,
        wr_en => fifo_encrypt_wr_en,
        rd_en => fifo_encrypt_rd_en,
        dout  => fifo_encrypt_dout,
        full  => fifo_encrypt_full,
        empty => fifo_encrypt_empty
    );

    uart_rx_Inst : uart_rx
    generic map(
        c_clkfreq  => c_clkfreq,
        c_baudrate => c_baudrate
    )
    port map(
        clk            => clk,
        rx_i           => RX_i,
        dout_o         => dout_o,
        rx_done_tick_o => rx_done_tick_o
    );

    uart_tx_Inst : uart_tx
    generic map(
        c_clkfreq  => c_clkfreq,
        c_baudrate => c_baudrate,
        c_stopbit  => c_stopbit
    )
    port map(
        clk            => CLK,
        din_i          => din_i,
        tx_start_i     => tx_start_i,
        tx_o           => TX_o,
        tx_done_tick_o => tx_done_tick_o
    );

    AES_Encrypt_Inst : AES_Encrypt
    port map(
        CLK         => CLK,
        aes_enable  => aes_enable,
        aes_stop    => aes_stop,
        aes_key     => aes_key,
        aes_message => aes_message,
        aes_out     => aes_out,
        aes_done    => aes_done,
        aes_valid   => aes_valid
    );

end Behavioral;