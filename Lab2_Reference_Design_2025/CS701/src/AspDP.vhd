library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.TdmaMinTypes.all;

entity AspDP is
	port (
		clock : in  std_logic;

		send  : out tdma_min_port;
		recv  : in  tdma_min_port
	);
end entity;

architecture rtl of AspDP is
type array_type is array (0 to 3) of std_logic_vector(15 downto 0);
signal avg_array : array_type := (others => (others => '0'));
signal addr   : std_logic_vector(3 downto 0) := "0010";
signal mode : std_logic_vector (3 downto 0);
begin

	process(clock)
	
	begin
		if rising_edge(clock) then

			if recv.data(31 downto 28) = "1001" then
				addr   <= recv.data(23 downto 20);
				mode   <= recv.data(19 downto 16);
			end if;

		end if;
	end process;

	process(clock)
	variable avg_data : signed(15 downto 0);
	begin
		if rising_edge(clock) then
			if recv.data(31 downto 28) = "1000" then
                avg_array(0) <= avg_array(1);
                avg_array(1) <= avg_array(2);
                avg_array(2) <= avg_array(3);
                avg_array(3) <= recv.data(15 downto 0);

                avg_data := shift_right(signed(avg_array(0)) + signed(avg_array(1))  + signed(avg_array(2))  + signed(avg_array(3)),1 );
                if avg_data > to_signed(4096,16) then
                    avg_data := to_signed(4096,16);
                elsif avg_data < to_signed(-4096,16) then
                    avg_data := to_signed(-4096,16);
                end if;
				send.addr <= "0000" & addr;
				send.data <= recv.data(31 downto 16) & std_logic_vector(avg_data);
            end if;
		end if;
	end process;

end architecture;
