library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control is
port(nRst:     in         std_logic;
     clk:      in         std_logic;                       -- 50 MHz
     dato_rd:  in         std_logic_vector(7 downto 0);    
     ena_rd:   in         std_logic;   			       -- Es para la operacion de lectura, le necesito a 1 para que me entreguen el byte                    
     rdy:      in         std_logic; 
     tic_5ms:  in         std_logic;	 
     start:    buffer     std_logic;                      
     nWR_RD:   buffer     std_logic;                       
     dir_reg:  buffer     std_logic_vector(6 downto 0);   
     dato_wr:  buffer     std_logic_vector(7 downto 0));   -- Es para otro modulo  
end entity;


architecture rtl of control is
 signal dato_leido: std_logic_vector( 7 downto 0); 
 signal tic_160ms: std_logic;
 signal cnt_tic_5ms: std_logic_vector(5 downto 0);
-- AUTOMATA
  type t_estado is (configuracion_reg4, configuracion_reg1, offset, medidas);
  signal estado : t_estado;

begin 

-- TIC DE 160 ms
  process(clk, nRst)
  begin
    if nRst = '0' then
	  cnt_tic_5ms <= (0 => '1', others => '0');
	  
	elsif clk'event and clk = '1' then
	  if tic_160ms = '1' then
	    cnt_tic_5ms <= (0 => '1', others => '0');
		
	  elsif estado = offset and tic_5ms = '1' then
	    cnt_tic_5ms <= cnt_tic_5ms + 1;
		
      end if;
	end if;
  end process;
  
  tic_160ms <= '1' when cnt_tic_5ms = 32 else
               '0';
			   
-- AUTOMATA

  process(clk, nRst)
  begin
    if nRst = '0' then
	  estado <= configuracion_reg4;
	  start <= '0';
	  nWR_RD <= '0';
	  dir_reg <= (others => '0');
	  dato_wr <= (others => '0');
	  
    elsif clk'event and clk = '1' then
       case estado is 
	    when configuracion_reg4 =>
	 -- Nos comunicamos con el master para escribir el registro 4 
              if rdy = '0' then
		 start <= rdy;                                                -- Instruccion para comenza la comunicacion
          	 nWR_RD <= '1';
		 dir_reg <= "0100011";                                            -- Direccion reg4
		 dato_wr <= "10000000";  -- X"80"	
		 estado <= configuracion_reg1;
	      end if;

           when configuracion_reg1 => 
          -- Nos comunicamos con el master para escribir el registro 1
	      if rdy = '0' then
		 start <= rdy;                                                -- Instruccion para comenza la comunicacion master spi
                 nWR_RD <= '1';                                               -- Escritura
	         dir_reg <= "0100000";                                         -- Direccion del reg1
                 dato_wr <= "01100001";                                       -- Habilitado solo el eje X por que tienes el Y tb
		 estado <= medidas;	
	       end if;

	   when medidas =>
             if tic_5ms = '1' then
		 start <= '1';
                 nWR_RD <= '1';
		 dir_reg <= "0100110"; 		-- dir_capture
	         
               if tic_160ms = '1' then			-- he realizado 32 medidas y puedo calcular el offset
	         estado <= offset;
               end if;

             end if;
							-- espero la medida
	    if ena_rd = '1' then
	        dato_leido <= dato_rd;    		-- el dato me lo manda el master			  
	    end if;

	    when offset =>     				-- Se realizaran lecturas durante 160 ms y se hara el promedio
             

	    
		  
		  
        end case;
     end if;
  end process;

end rtl;
