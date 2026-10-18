library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_genImm32 is
end tb_genImm32;

architecture test of tb_genImm32 is
    -- Componente a ser testado
    component genImm32
        port (
            instr : in std_logic_vector(31 downto 0);
            imm32 : out signed(31 downto 0)
        );
    end component;

    -- Sinais internos para conexão
    signal instr_in : std_logic_vector(31 downto 0) := (others => '0');
    signal imm32_out : signed(31 downto 0);
begin
    -- Instanciação do módulo
    UUT: genImm32 port map (
        instr => instr_in,
        imm32 => imm32_out
    );

    -- Processo de estímulos (Aplicando os valores da tabela de verificação)
    stim_proc: process
    begin
        -- add t0, zero, zero (R-type)
        instr_in <= x"000002b3";
        wait for 10 ns;

        -- lw t0, 16(zero) (I-type0)
        instr_in <= x"01002283";
        wait for 10 ns;

        -- addi t1, zero, -100 (I-type1)
        instr_in <= x"f9c00313";
        wait for 10 ns;

        -- xori t0, t0, -1 (I-type1)
        instr_in <= x"fff2c293"; 
        wait for 10 ns;

        -- addi t1, zero, 354 (I-type1)
        instr_in <= x"16200313";
        wait for 10 ns;

        -- jalr zero, zero, 0x18 (I-type2)
        instr_in <= x"01800067";
        wait for 10 ns;

        -- srai t1, t2, 10 (I-type*)
        instr_in <= x"40a3d313";
        wait for 10 ns;

        -- lui s0, 2 (U-type)
        instr_in <= x"00002437";
        wait for 10 ns;

        -- sw t0, 60(s0) (S-type)
        instr_in <= x"02542e23";
        wait for 10 ns;

        -- bne t0, t0, main (SB-type)
        instr_in <= x"fe5290e3";
        wait for 10 ns;

        -- jal rot (UJ-type)
        instr_in <= x"00c000ef";
        wait for 10 ns;

        wait; -- Fim da simulação
    end process;
end test;