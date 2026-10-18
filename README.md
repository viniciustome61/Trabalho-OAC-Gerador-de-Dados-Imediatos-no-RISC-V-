# Geração de Imediatos 32-bit (genImm32) — RISC-V

Resumo
------
Implementação em VHDL de um gerador de imediatos 32-bit para instruções RISC‑V, com um testbench que aplica vetores de teste cobrindo os formatos I, S, SB, U, UJ, R e um caso especial para shift aritmético imediato (srai). O projeto acompanha um relatório em PDF com a especificação e justificativas.

O propósito
----------
O módulo genImm32 extrai e formata o campo imediato de instruções RISC‑V de 32 bits, realizando extensão de sinal ou concatenação conforme o formato da instrução. É útil em pipelines e unidades de decodificação que precisam do imediato pronto para operação aritmética, acesso à memória ou cálculo de desvio/salto.

Stack
-----
- Linguagem: VHDL (IEEE STD_LOGIC_1164, NUMERIC_STD)
- Testbench: VHDL (simulação funcional)
- Ferramentas sugeridas: GHDL, ModelSim/QuestaSim, Vivado Simulator
- Arquivos principais: `genImm32.vhd`, `tb_genImm32.vhd`
- Documento: `Trabalho OAC - Geração de Dados Imediatos no RISC-V .pdf` (relatório do trabalho)

Estrutura do repositório (top-level)
------------------------------------
```
Trabalho OAC - Geração de Dados Imediatos no RISC-V .pdf   # Relatório/entrega (PDF)
genImm32.vhd                                             # Módulo gerador de imediato (VHDL)
tb_genImm32.vhd                                          # Testbench (VHDL) com vetores de teste
```

O que faz `genImm32.vhd`
------------------------
- Lê a instrução de 32 bits (`instr : std_logic_vector(31 downto 0)`).
- Extrai `opcode` (bits 6 downto 0) e `funct3` (bits 14 downto 12).
- Produz `imm32 : signed(31 downto 0)` de acordo com o formato:
  - R-type: imediato = 0
  - I-type (opcodes 0x03, 0x13, 0x67): imm(11:0) = instr(31:20) com extensão de sinal
    - Caso especial I-type* para SRAI (opcode 0x13, funct3 = 101 e instr(30) = '1'): o módulo trata `imm` como zero-extend do campo shamt (`instr(24 downto 20)`).
  - S-type (opcode 0x23): imm(11:0) = instr(31:25) & instr(11:7) com extensão de sinal
  - SB-type (opcode 0x63): imm(12:1) formado por {instr(31), instr(7), instr(30:25), instr(11:8)} e LSB = 0, com extensão de sinal
  - U-type (opcode 0x37): imm(31:12) = instr(31:12) concatenado com 12 bits zero
  - UJ-type (opcode 0x6F): imm(20:1) = {instr(31), instr(19:12), instr(20), instr(30:21)} e LSB = 0, com extensão de sinal

Testbench (`tb_genImm32.vhd`)
-----------------------------
O testbench aplica uma sequência de instruções (em hex) que cobrem os formatos e casos de borda, por exemplo:

- x"000002b3"  — add (R-type)                -> imm esperado: 0
- x"01002283"  — lw t0, 16(zero) (I-type)    -> imm esperado: 16
- x"f9c00313"  — addi t1, zero, -100 (I-type)-> imm esperado: -100
- x"fff2c293"  — xori t0, t0, -1 (I-type)    -> imm esperado: -1
- x"16200313"  — addi t1, zero, 354 (I)      -> imm esperado: 354
- x"01800067"  — jalr zero, zero, 0x18 (I)   -> imm esperado: 24
- x"40a3d313"  — srai t1, t2, 10 (I-type*)   -> imm especial (shamt) esperado: 10
- x"00002437"  — lui s0, 2 (U-type)          -> imm esperado: 2 << 12 = 8192
- x"02542e23"  — sw t0, 60(s0) (S-type)      -> imm esperado: 60
- x"fe5290e3"  — bne t0, t0, main (SB-type)  -> imm conforme offset de branch
- x"00c000ef"  — jal rot (UJ-type)           -> imm conforme offset de salto

Como simular (exemplos)
-----------------------

Usando GHDL (open-source):
1. Analisar os fontes:
   ```
   ghdl -a genImm32.vhd tb_genImm32.vhd
   ```
2. Elaborar o testbench:
   ```
   ghdl -e tb_genImm32
   ```
3. Rodar a simulação e gerar VCD para visualização:
   ```
   ghdl -r tb_genImm32 --vcd=sim.vcd
   ```
   Abrir `sim.vcd` em um visualizador como GTKWave:
   ```
   gtkwave sim.vcd
   ```

Usando ModelSim / QuestaSim:
1. Compilar:
   ```
   vcom genImm32.vhd tb_genImm32.vhd
   ```
2. Simular:
   ```
   vsim work.tb_genImm32
   run -all
   ```
   Em GUI, adicione o sinal `imm32` à waveform para verificar os valores.

O que verificar na simulação
----------------------------
- Verificar que `imm32` assume os valores esperados para cada vetor de teste.
- Confirmar tratamento especial do SRAI (imediato com shamt zero-extend).
- Verificar extensão de sinal correta em immediatos negativos (ex.: -100, -1).
- Para U e UJ, confirmar que os bits superiores são posicionados corretamente (U: alto 20 bits << 12; UJ: montagem do immediate de 20 bits e LSB = 0).

Observações e limitações
------------------------
- O código trata SRAI como um caso especial (extrai o shamt e faz zero-extend).
- A concatenação para U-type utiliza `instr(31 downto 12) & x"000"` — ao simular/verificar, confirme que a ferramenta aceita essa forma (algumas ferramentas podem requerer conversões explícitas de tipos).
- Não há suporte a extensões RVC (compressas) — somente instruções RV32I padrão de 32 bits.

Referências
----------
- Arquivo fonte: `genImm32.vhd`
- Testbench: `tb_genImm32.vhd`
- Relatório detalhado: `Trabalho OAC - Geração de Dados Imediatos no RISC-V .pdf`
