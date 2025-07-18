library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity master_spi_4_hilos is
port(nRst:     in     std_logic;
     clk:      in     std_logic;                       -- 50 MHz
     dato_rd:  in     std_logic_vector(7 downto 0);    
     ena_rd:   in     std_logic;   			       -- Es para la operacion de lectura, le necesito a 1 para que me entreguen el byte                    
     rdy:      in     std_logic; 
     tic_5ms:  in     std_logic;	 
     start:    buffer     std_logic;                      
     nWR_RD:   buffer     std_logic;                       
     dir_reg:  buffer     std_logic_vector(6 downto 0);   
     dato_wr:  buffer     std_logic_vector(7 downto 0));   -- Es para otro modulo  
end entity;


architecture rtl of master_spi_4_hilos is
 signal cnt: std_logic_vector(2 downto 0);
 signal dato_leido: std_logic_vector(7 downto 0); 
 signal dato_leido: std_logic_vector(7 downto 0);
 
 -- timers
 signal tic_160ms: std_logic;
 signal cnt_tic_5ms: std_logic_vector(5 downto 0);
 
 constant scal_160ms: natural := 32; 
 
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
  
  tic_160ms <= '1' when cnt_tic_5ms = scal_160ms then
               '0';

-- PROMEDIO DE LAS MEDIDAS PARA REALIZAR EL VALOR DE REFERENCIA (offset)

			
-- AUTOMATA
  process(clk, nRst)
  begin
    if nRst = '0' then
	  estado <= configuracion;
	  start <= '0';
	  nWR_RD <= '0';
	  dir_reg <= (others => '0');
	  dato_wr <= (others => '0');
	  
	elsif clk'event and clk = '1' then
	  case estado is 
	    when configuracion_reg4 =>
		  -- Nos comunicamos con el master para escribir el registro 4 
		  if rdy = '1' then
		    start <= rdy;                                                -- Instruccion para comenza la comunicacion
            nWR_RD <= '0';
		    dir_reg <= X"23";                                            -- Direccion reg4
		    dato_wr <= "10000000";  -- X"80"
		
	      else 
		    estado <= configuracion_reg1;
			
		  end if;

        when configuracion_reg1 => 
          -- Nos comunicamos con el master para escribir el registro 1
		  -- Cuidado que puede cambiar otra vez de estado sin que haya terminado la primera medida
		  if rdy = '1' then
		    start <= rdy;                                                -- Instruccion para comenza la comunicacion master spi
            nWR_RD <= '0';                                               -- Escritura
		    dir_reg <= X"20";                                            -- Direccion del reg1
		    dato_wr <= "01100001";                                       -- Habilitado solo el eje X por que tienes el Y tb
		
	      else 
		    estado <= offset;    -- Cambio de estado cuando se han mandado todos los datos al master y la comunicacion esta en transito rdy = '0'
			
		  end if;
		  
		when offset =>     -- Se realizaran lecturas durante 160 ms y se hara el promedio
		  if tic_160ms = '1' then
		    estado <= medidas;
			
	      elsif tic_5ms = '1' and rdy = '1' then   -- Una lectura tarda 5 us en realizarse
			start <= rdy;                                                -- Instruccion para comenza la comunicacion master spi
            nWR_RD <= '1';
			if ena_rd = '1' then
			  dato_leido <= dato_rd;
			  
			end if;
	      end if;
				
		when medidas =>
		  if tic_5ms = '1' then
		    start <= 
			nWR_RD <= '1';
			dir_reg <= "1101000";                  -- DIRECCION DEL REGISTRO OUT_X_L  dir_reg(6) = '1' incremento de la direccion
			if ena_rd = '1' then
			  dato_medido <= dato_rd;
			  
			end if;
	      end if;
		  
      end case;
	end if;
  end process;
  
  dato_medida <= 

end rtl;
