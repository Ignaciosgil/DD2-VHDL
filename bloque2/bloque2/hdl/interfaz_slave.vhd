library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity interfaz_slave is
port(clk:          in     std_logic;
     nRST:         in     std_logic;
     MSB_1st:      in     std_logic;
     mode_3_4_h:   in     std_logic;
     str_sgl_ins:  in    std_logic; 
     nCs:          in    std_logic;
     SDI:          in    std_logic;
     SPC :         in    std_logic;
     reg_slave:    buffer    std_logic_vector (3 downto 0);
     reg_conf:     buffer std_logic_vector(15 downto 0);
     SDO :         buffer std_logic);
end entity;

architecture estructural of interfaz_slave is
   signal puntero:                std_logic_vector(15 downto 0);
   signal datos:                 std_logic_vector(7 downto 0);
   signal Dout:                  std_logic_vector(7 downto 0);
   signal desplazar_bit:         std_logic;   
   signal cargar_dato_SDO:       std_logic;
   signal load:			 std_logic;
	signal ctrl:			std_logic;

   signal WE:                    std_logic;
 --  signal reg_conf:   std_logic_vector(15 downto 0);  
   
begin 
   U0: entity work.bancoregistros4(rtl)
    port map(clk          => clk,
             nRST         => nRST,
             Din          => datos,    -- Esta se�al la recibo de el control
             puntero      => puntero, 
             reg_conf     => reg_conf,
             WE           => WE,
	     reg_slave 	  => reg_slave,
             Dout         => Dout);    -- Esto sale del banco al reg_out
 
             
   U1: entity work.control_esclavo(rtl)
    port map(clk                 => clk,
             nRST                => nRST,
             nCS                 => nCs,
             SPC                 => SPC,
             SDI                 => SDI,
             puntero             => puntero,
	     WE                  => WE,
	     ctrl                => ctrl,
	     load		 => load,             desplazar_bit       => desplazar_bit,
             reg_conf            => reg_conf,
             datos               => datos);   
             
   U2: entity work.reg_salida_SDO(rtl)
    port map(clk           => clk,
             nRST          => nRST,
             dato_out      => Dout,
	     ctrl          => ctrl,
	     load 	   => load,	
             desplazar_bit => desplazar_bit,
             MSB_1st  	   => MSB_1st,
             SDO           => SDO);

end estructural;
 

  