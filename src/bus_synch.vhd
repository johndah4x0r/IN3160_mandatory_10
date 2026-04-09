library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bus_synch is
    generic (
        WIDTH       : natural := 32
    );

    port (
        mclk        : in std_ulogic;
        bus_in      : in signed(WIDTH-1 downto 0);
        bus_out     : out signed(WIDTH-1 downto 0)
    );
end entity bus_synch;

architecture rtl of bus_synch is
    signal buf_b, buf_c, next_out   : std_ulogic_vector(WIDTH-1 downto 0);
    signal update                   : std_ulogic;
begin
    -- internal brute-force synchronizer
    inner: entity work.synch(rtl)
        generic map (
            WIDTH => WIDTH
        )

        port map (
            clk => mclk,
            n => std_ulogic_vector(bus_in),
            n_synch => buf_b
        );
    
    -- bubble register process
    bubble: process(mclk) is
    begin
        if rising_edge(mclk) then
            buf_c <= buf_b;
        end if;
    end process;

    -- main register process
    reg: process(mclk) is
    begin
        if rising_edge(mclk) then
            if update = '1' then
                next_out <= buf_c;
            end if;
        end if;
    end process;

    -- combinational logic
    -- (raise update only if `buf_b == buf_c`)
    bus_out <= signed(next_out);    
    update <= '0' when or(buf_b xor buf_c) = '1' else '1';
end architecture rtl;
