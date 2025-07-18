library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_top is
end entity;

architecture test of test_top is
  signal nRst:     std_logic;
  signal clk:      std_logic;                                                         
  signal nCS:      std_logic;                      
  signal SPC:      std_logic;                      
  signal SDI_msr:  std_logic;                     -- SDI master                      
  signal SDO_msr:  std_logic;                     -- SDO master
  signal LEDs:     std_logic_vector(7 downto 0);
  signal mux_disp: std_logic_vector(7 downto 0);
  signal seg:      std_logic_vector(7 downto 0);

  constant T_clk: time := 20 ns;

  signal pos_X: std_logic_vector(1 downto 0);

begin

process
begin
  clk <= '0';
  wait for T_clk/2;

  clk <= '1';
  wait for T_clk/2;

end process;

dut: entity work.top(estructural)
     generic map(fdc_cnt => 140)

     port map(nRst     => nRst,
              clk      => clk,
              nCS      => nCS,
              SPC      => SPC,
              SDI      => SDI_msr,
              SDO      => SDO_msr,
              LEDs     => LEDs);

slave: entity work.agente_spi(sim)
       port map(pos_X => pos_X,
                nCS => nCS,
                SPC => SPC,
                SDI => SDO_msr,
                SDO => SDI_msr);

process
begin
  nRst <= '1';
  wait until clk'event and clk = '1';
  wait until clk'event and clk = '1';
    nRst <= '0';
    pos_X <= "00";


  wait until clk'event and clk = '1';
  wait until clk'event and clk = '1';
    nRst <= '1';

  --Configuración y calculo de offset
  for i in 1 to 35 loop
    wait until nCS'event and nCS = '1';

  end loop;

  -- Prueba de posiciones
  pos_X <="00";


  for i in 1 to 20 loop
    wait until nCS'event and nCS = '1';

  end loop;

  -- Prueba de posiciones
  pos_X <="01";


  for i in 1 to 20 loop
    wait until nCS'event and nCS = '1';

  end loop;

  -- Prueba de posiciones
  pos_X <="10";


  for i in 1 to 20 loop
    wait until nCS'event and nCS = '1';

  end loop;


  wait for 100 * T_clk;

  assert false
  report "Fone"
  severity failure;

end process;
end test;