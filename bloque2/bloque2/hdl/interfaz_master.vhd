library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity top is
end entity;
--Lo de la derecha es lo que yo tengo en mi modulo y lo
--de la izquierda con lo que lo asocio 
architecture estructural of top is
  signal nRst:     std_logic;
  signal clk:      std_logic; 
  signal nCs:      std_logic;
  signal SDI_msr:  std_logic;
  signal SPC :     std_logic;
  signal SDO_msr : std_logic;
  signal tic_5ms:  std_logic;
  signal dato_rd:  std_logic_vector(7 downto 0);
  signal rdy:      std_logic;
  signal start:    std_logic;
  signal dir_reg:  std_logic_vector(6 downto 0);
  signal ena_rd:   std_logic;
  signal dato_wr:  std_logic_vector(7 downto 0);
  signal nWR_RD:   std_logic;
 
begin 
   U0: entity work.control(rtl)
    port map(clk          => clk,
             nRST         => nRST,
             tic_5ms      => tic_5ms,
             dato_rd      => dato_rd,
             ena_rd       => ena_rd,   
             rdy          => rdy,
             start        => start,
             nWR_RD       => nWR_RD,
             dir_reg      => dir_reg,
             dato_wr      => dato_wr);

   U1: entity work.timer(rtl)
    port map(clk         => clk,
             nRST        => nRST,
             tic_5ms     => tic_5ms);

   U2: entity work.master_spi_4_hilos(rtl)
    port map(clk          => clk,
             nRST         => nRST,
             dato_rd      => dato_rd,
             ena_rd       => ena_rd,   
             rdy          => rdy,
             start        => start,
             nWR_RD       => nWR_RD,
             dir_reg      => dir_reg,
             dato_wr      => dato_wr,
             nCS          => nCs,
             SPC          => SPC,
             SDI          => SDI_msr,
             SDO          => SDO_msr);
             

end estructural;
 

