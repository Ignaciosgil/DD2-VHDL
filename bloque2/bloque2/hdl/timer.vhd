library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity timer_medida is
		
port(clk:       in     std_logic;
     nRst:      in     std_logic;
     tic_2_5ms: buffer std_logic;
     tic_5ms:   buffer std_logic;
     tic_0_5s:  buffer std_logic
    );          
end entity;

architecture rtl of timer_medida is
  signal cnt_timer_2_5ms:   std_logic_vector(16 downto 0);
  signal cnt_timer_0_5s:   std_logic_vector(24 downto 0);
  signal cnt_timer_5ms:   std_logic_vector(1 downto 0);

  constant fdc_timer_2_5ms: natural := 125000;
  constant fdc_timer_0_5s: natural :=100;
  constant fdc_timer_5ms: natural :=1; 
  
begin
  --Timer 0.25 s (tic = 2.5 ms)
  process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_timer_2_5ms <= (0 => '1', others => '0');

    elsif clk'event and clk = '1' then
      if tic_2_5ms = '1' then
        cnt_timer_2_5ms <= (0 => '1', others => '0');
		  
      else
        cnt_timer_2_5ms <= cnt_timer_2_5ms + 1;

      end if;
    end if;
  end process;

  tic_2_5ms <= '1' when cnt_timer_2_5ms = fdc_timer_2_5ms else
               '0';

  -- generacion tic 0,5s
  process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_timer_0_5s <= (0 => '1', others => '0');

    elsif clk'event and clk = '1' then
      if tic_0_5s = '1' then
        cnt_timer_0_5s <= (0 => '1', others => '0');
		  
      elsif tic_5ms = '1' then
        cnt_timer_0_5s <= cnt_timer_0_5s + 1;

      end if;
    end if;
  end process;

  tic_0_5s <= '1' when cnt_timer_0_5s = fdc_timer_0_5s and tic_5ms = '1' else
               '0';

    -- generacion tic 5 ms
  process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_timer_5ms <= (0 => '1', others => '0');

    elsif clk'event and clk = '1' then
      if tic_5ms = '1' then
        cnt_timer_5ms <= (0 => '1', others => '0');
		  
      elsif tic_2_5ms = '1' then
        cnt_timer_5ms <= cnt_timer_5ms + 1;

      end if;
    end if;
  end process;

  tic_5ms <= '1' when cnt_timer_5ms = fdc_timer_5ms and tic_2_5ms = '1' else
               '0';
end rtl;