library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity interfaz_master is
port(clk:         in     std_logic;
     nRST:        in     std_logic;     
     dato_rd:     buffer     std_logic_vector(7 downto 0);
     rdy:         buffer     std_logic;
     --tic_5ms:     buffer std_logic;
     start:       buffer std_logic;
     dir_reg:     buffer std_logic_vector(6 downto 0);
     ena_rd:      buffer std_logic;
     dato_wr:     buffer std_logic_vector(7 downto 0);
     nWR_RD:      buffer std_logic);

end entity;

--Lo de la derecha es lo que yo tengo en mi modulo y lo
--de la izquierda con lo que lo asocio 
architecture estructural of interfaz_master is                                                  
  signal nCS:      std_logic;                      
  signal SPC:      std_logic;                      
  signal SDI_msr:  std_logic;                                    
  signal SDO_msr:  std_logic;   
  signal tic_5ms:  std_logic;  

 
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
             start        => start,
             nWR_RD       => nWR_RD,
             dir_reg      => dir_reg,
             dato_wr      => dato_wr,
             dato_rd      => dato_rd,
             ena_rd       => ena_rd,   
             rdy          => rdy,
             nCS          => nCS,
             SPC          => SPC,
             SDI          => SDI_msr,
             SDO          => SDO_msr);
             

end estructural;
 


