-- High load test project.
-- Alexey Fedorov, 2014
-- email: FPGA@nerudo.com
--
-- It implements 256 LUT/DFFs per one row (NUM_ROWS parameter) 
-- with default other parameters

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity lc_use is
	generic (
		DATA_WIDTH : positive := 128; 
		ARITH_SIZE : positive := 16; -- Should be divider of DATA_WIDTH
		NUM_ROWS: positive := 6	-- Input pins
		);
	port
	(
		clk	: in  std_logic;
		inputs: in std_logic_vector(DATA_WIDTH-1 downto 0);
		dataout: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end lc_use;


architecture rtl of lc_use is
type TArr is array (natural range <>) of unsigned(127 downto 0);
signal arr : TArr(0 to 2*NUM_ROWS) := (others => (others => '0'));

begin

assert DATA_WIDTH mod ARITH_SIZE = 0 report "ARITH_SIZE should be divider of DATA_WIDTH" severity error;

process(clk)
begin
if rising_edge(clk) then
	arr(0)(DATA_WIDTH-1 downto 0) <= unsigned(inputs);
	for i in 0 to NUM_ROWS-1 loop
		arr(2*i+1) <= arr(2*i) xor (arr(2*i) rol 1) xor (arr(2*i) rol 2) xor (arr(2*i) rol 3);
		for j in 0 to DATA_WIDTH/ARITH_SIZE-1 loop
			arr(2*i+2)((j+1)*ARITH_SIZE - 1 downto j*ARITH_SIZE) <= 
				arr(2*i+0)((j+1)*ARITH_SIZE - 1 downto j*ARITH_SIZE) +
				arr(2*i+1)((j+1)*ARITH_SIZE - 1 downto j*ARITH_SIZE);
		end loop;
	end loop;
	
	dataout <= std_logic_vector(arr(2*NUM_ROWS));

end if;

end process;

end rtl;
