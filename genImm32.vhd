library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entradas e saídas conforme especificado no documento
entity genImm32 is
    port (
        instr: in std_logic_vector(31 downto 0);
        imm32: out signed (31 downto 0)
    );
end genImm32;

architecture Behavioral of genImm32 is
    signal opcode : std_logic_vector(6 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
begin
    -- O campo opcode consiste nos 7 bits menos significativos da instrução
    opcode <= instr(6 downto 0);
    -- O campo funct3 localiza-se nos bits 14 a 12
    funct3 <= instr(14 downto 12);

    process(instr, opcode, funct3)
    begin
        case opcode is
            -- Formato R_type: opcode = 0x33
            when "0110011" => 
                imm32 <= (others => '0');

            -- Formato I_type: opcodes = 0x03, 0x13, ou 0x67
            when "0000011" | "0010011" | "1100111" => 
                -- Verificação especial para I_type* (instrução srai)
                -- opcode = 0x13, funct3 = 5, inst(30) = 1
                if (opcode = "0010011" and funct3 = "101" and instr(30) = '1') then
                    -- I-type*: imm(4:0) = ins(24:20) e imm(31:5) = 0
                    imm32 <= resize(signed("0" & instr(24 downto 20)), 32);
                else
                    -- I-type padrão: imm(11:0) = ins(31:20) com extensão de sinal
                    imm32 <= resize(signed(instr(31 downto 20)), 32);
                end if;

            -- Formato S_type: opcode = 0x23
            when "0100011" => 
                -- imm(11:0) = {ins(31:25), ins(11:7)} com extensão de sinal
                imm32 <= resize(signed(instr(31 downto 25) & instr(11 downto 7)), 32);

            -- Formato SB_type: opcode = 0x63
            when "1100011" => 
                -- imm(12:1) = {ins(31), ins(7), ins(30:25), ins(11:8)}, imm(0) = 0 com extensão de sinal
                imm32 <= resize(signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'), 32);

            -- Formato U_type: opcode = 0x37
            when "0110111" => 
                -- imm(31:12) = ins(31:12) e imm(11:0) = 0
                -- Aqui concatenamos com 12 zeros diretos
                imm32 <= signed(instr(31 downto 12) & x"000");

            -- Formato UJ_type: opcode = 0x6F
            when "1101111" => 
                -- imm(20:1) = {ins(31), ins(19:12), ins(20), ins(30:21)}, imm(0) = 0 com extensão de sinal
                imm32 <= resize(signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'), 32);

            -- Caso padrão para evitar latches indesejados
            when others =>
                imm32 <= (others => '0');
        end case;
    end process;
end Behavioral;