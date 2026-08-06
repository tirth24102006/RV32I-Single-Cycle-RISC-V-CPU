## RV32I Single-Cycle RISC-V CPU 

A minimal single-cycle 32-bit RISC-V (RV32I) CPU built from scratch in Verilog HDL, executing ADD and ADDI. Fully modular datapath — PC, instruction memory, register file, ALU, control unit, ALU control, immediate generator, and ALU-source mux — each with its own testbench, simulated in Icarus Verilog and visualized in GTKWave & Vivado. 🚀

--- 

# 🧠 RV32I Single-Cycle RISC-V CPU (9-Instruction ALU Subset)

### Built from scratch in Verilog HDL

> ⚙️ A fully modular, single-cycle 32-bit RISC-V processor, hand-built in Verilog HDL from the ground up — implementing 9 R-type ALU instructions (`ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SLT`, `SLTU`, `SRL`) and their matching I-type immediate forms (`ADDI`, `ANDI`, `ORI`, `XORI`, `SLLI`, `SLTI`, `SLTIU`, `SRLI`) from the RV32I base integer instruction set. Every stage of the classic **Fetch → Decode → Execute → Write-Back** pipeline is broken into its own clean, independently testable module. Simulated with Icarus Verilog, inspected in GTKWave, and synthesizable in Xilinx Vivado. 🚀

> 🏁 **Status:** Feature-complete for its intended scope. The core fully and correctly supports the 9 ALU operations above (both R-type and I-type forms) — verified end-to-end, including signed vs. unsigned comparison (`SLT` vs `SLTU`) and negative-immediate sign-extension. `SRA`/`SRAI` are **intentionally out of scope** (see [Design Decisions](#17--key-design-decisions)), and loads/stores/branches/jumps are noted as possible future work in the [roadmap](#16--current-limitations--roadmap) below, not planned for this version.

---

## 📑 Table of Contents

1. [Project Highlights](#1--project-highlights)
2. [RISC-V, RISC vs CISC, and RV32I](#2--risc-v-risc-vs-cisc-and-rv32i)
3. [Instruction Encoding — R-type & I-type](#3--instruction-encoding--r-type--i-type)
4. [How the Single-Cycle Pipeline Works](#4--how-the-single-cycle-pipeline-works)
5. [How the Whole CPU Works — End-to-End Walkthrough](#5--how-the-whole-cpu-works--end-to-end-walkthrough)
6. [Project Structure (File Hierarchy)](#6--project-structure-file-hierarchy)
7. [Module-by-Module Breakdown](#7--module-by-module-breakdown)
8. [Test Program Used for Verification](#8--test-program-used-for-verification)
9. [How to Download This Project](#9--how-to-download-this-project)
10. [How to Run on Windows](#10--how-to-run-on-windows)
11. [How to Run on macOS / Linux](#11--how-to-run-on-macos--linux)
12. [Sample Simulation Output](#12--sample-simulation-output)
13. [Debugging Journey — Bugs Found & Fixed](#13--debugging-journey--bugs-found--fixed)
14. [Verilog Concepts Reference](#14--verilog-concepts-reference)
15. [Glossary of Terms](#15--glossary-of-terms)
16. [Current Limitations & Roadmap](#16--current-limitations--roadmap)
17. [Key Design Decisions](#17--key-design-decisions)
18. [Author](#18--author)
19. [License](#19--license)

---

## 1. 📌 Project Highlights

- ✅ Fully working **single-cycle 32-bit RISC-V datapath**, built entirely from first principles
- ✅ Implements **9 ALU operations** in both R-type and I-type form — `ADD/ADDI`, `SUB`, `AND/ANDI`, `OR/ORI`, `XOR/XORI`, `SLL/SLLI`, `SLT/SLTI`, `SLTU/SLTIU`, `SRL/SRLI` — all matching the official RISC-V ISA encoding bit-for-bit
- ✅ Correct **signed vs. unsigned comparison** — `SLT`/`SLTI` use signed comparison, `SLTU`/`SLTIU` use unsigned, selected via a dedicated `flag` signal derived from `funct3`
- ✅ **9 independent hardware modules**, each with its own dedicated testbench (18 files total)
- ✅ Working **32×32 register file** with `x0` hardwired to zero, exactly as the spec requires
- ✅ Combinational **instruction memory** with correct byte-to-word address translation
- ✅ Proper **sign-extended immediate generation**, tested against negative immediates
- ✅ Clean separation of **control logic** from the **datapath** — the same principle real CPUs use
- ✅ `pc_out` exposed as a real top-level output — keeps the design synthesis-safe in Vivado (see [Design Decisions](#17--key-design-decisions))
- ✅ Full-system testbench that loads a multi-instruction program and verifies every register
- ✅ Verified with **Icarus Verilog + GTKWave**, structured to be synthesizable in **Xilinx Vivado**

---

## 2. 🧠 RISC-V, RISC vs CISC, and RV32I

### RISC vs CISC

| | CISC (e.g. x86) | RISC (e.g. RISC-V, ARM, MIPS) |
|---|---|---|
| Instructions | Complex — one instruction can do several things | Simple — one instruction, one operation |
| Length | Variable (1–15 bytes) | Fixed (32 bits in RV32I) |
| Memory access | Any instruction can touch memory | Only `LOAD`/`STORE` touch memory |
| Philosophy | Smart hardware, simple compiler | Simple hardware, smart compiler |
| Pipelining | Harder — variable-length decode | Easy — fixed, uniform fields |

RISC-V's fixed 32-bit instructions with clean, uniform bit-fields are exactly what makes a **single-cycle CPU** like this one feasible to hand-build — a CISC ISA like x86 would be far too complex to decode and execute in one clock cycle.

### Why "RISC-V"? 🔢

The **"V"** is the Roman numeral **5** — this is literally the **fifth** RISC architecture in a research lineage from UC Berkeley:

```
RISC-I  →  RISC-II  →  RISC-III (SOAR)  →  RISC-IV (SPUR)  →  RISC-V
```

It isn't a "version 5.0" in the software sense — it's the fifth research chip in that lineage, which then became a free, open, royalty-free ISA standard, unlike proprietary ISAs such as x86 (Intel/AMD) or ARM (licensed).

### What is RV32I?

| Part | Meaning |
|---|---|
| **RV** | RISC-V |
| **32** | 32-bit registers & address space |
| **I** | Base **Integer** instruction set — mandatory minimum every RISC-V CPU must support |

RV32I contains roughly **47 base instructions**. This project implements a focused subset — the 9 core ALU operations (`ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SLT`, `SLTU`, `SRL`) in both R-type and I-type form — enough to prove out the entire datapath end-to-end, including signed vs. unsigned comparison and negative-immediate handling, without the added complexity of memory access or control flow.

---

## 3. 🔍 Instruction Encoding — R-type & I-type

Every RISC-V instruction is a fixed **32 bits wide**. All 9 instructions this core supports use one of these two formats:

**R-type** (e.g. `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SLT`, `SLTU`, `SRL`)

```
 31        25 24     20 19     15 14    12 11      7 6        0
┌────────────┬─────────┬─────────┬────────┬──────────┬─────────┐
│   funct7   │   rs2   │   rs1   │ funct3 │    rd    │  opcode │
└────────────┴─────────┴─────────┴────────┴──────────┴─────────┘
```

**I-type** (e.g. `ADDI`, `ANDI`, `ORI`, `XORI`, `SLLI`, `SLTI`, `SLTIU`, `SRLI`)

```
 31                  20 19     15 14    12 11      7 6        0
┌──────────────────────┬─────────┬────────┬──────────┬─────────┐
│      imm[11:0]       │   rs1   │ funct3 │    rd    │  opcode │
└──────────────────────┴─────────┴────────┴──────────┴─────────┘
```

**Full encoding table for every instruction this core supports:**

| Instruction | opcode | funct3 | funct7 | Type | Operation |
|---|---|---|---|---|---|
| `ADD`  | `0110011` | `000` | `0000000` | R | `rd = rs1 + rs2` |
| `SUB`  | `0110011` | `000` | `0100000` | R | `rd = rs1 - rs2` |
| `SLL`  | `0110011` | `001` | `0000000` | R | `rd = rs1 << rs2[4:0]` |
| `SLT`  | `0110011` | `010` | `0000000` | R | `rd = (rs1 < rs2) ? 1 : 0` (**signed**) |
| `SLTU` | `0110011` | `011` | `0000000` | R | `rd = (rs1 < rs2) ? 1 : 0` (**unsigned**) |
| `XOR`  | `0110011` | `100` | `0000000` | R | `rd = rs1 ^ rs2` |
| `SRL`  | `0110011` | `101` | `0000000` | R | `rd = rs1 >> rs2[4:0]` (zero-fill) |
| `OR`   | `0110011` | `110` | `0000000` | R | `rd = rs1 \| rs2` |
| `AND`  | `0110011` | `111` | `0000000` | R | `rd = rs1 & rs2` |
| `ADDI`  | `0010011` | `000` | — | I | `rd = rs1 + sign_ext(imm)` |
| `SLLI`  | `0010011` | `001` | — | I | `rd = rs1 << imm[4:0]` |
| `SLTI`  | `0010011` | `010` | — | I | `rd = (rs1 < sign_ext(imm)) ? 1 : 0` (**signed**) |
| `SLTIU` | `0010011` | `011` | — | I | `rd = (rs1 < sign_ext(imm)) ? 1 : 0` (**unsigned**) |
| `XORI`  | `0010011` | `100` | — | I | `rd = rs1 ^ sign_ext(imm)` |
| `SRLI`  | `0010011` | `101` | — | I | `rd = rs1 >> imm[4:0]` (zero-fill) |
| `ORI`   | `0010011` | `110` | — | I | `rd = rs1 \| sign_ext(imm)` |
| `ANDI`  | `0010011` | `111` | — | I | `rd = rs1 & sign_ext(imm)` |

> 🧾 **Sign extension:** the 12-bit `imm[11:0]` field is extended to 32 bits by replicating bit `[31]` of the instruction across bits `[31:12]` — implemented as `{{20{instruction[31]}}, instruction[31:20]}`.
>
> ⚠️ **`SRA`/`SRAI` are intentionally not implemented.** Both would share `funct3 = 101` with `SRL`/`SRLI`, distinguished only by `funct7`. This core deliberately does not check `funct7` for that case, so only the logical right-shift (`SRL`/`SRLI`) is supported — see [Design Decisions](#17--key-design-decisions) for why this was a scoped choice rather than an oversight.

---

## 4. 🔄 How the Single-Cycle Pipeline Works

Unlike a shared-bus, multi-cycle design, this CPU executes **one full instruction, start to finish, in a single clock cycle**. Only the Program Counter and Register File are actual clocked registers — everything else is combinational logic that settles within that same cycle.

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│      PC      │───▶│  Instr Mem   │───▶│   Decoder    │───▶│   Reg File   │───▶│     ALU      │
└──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘
                                                                                        │ write-back
                                                                    ┐───────────────────┘
                                                                    ▼
                                                                 (write rd)
```

### Stage by stage

| Stage | What happens |
|---|---|
| **1. Fetch** | `pc_reg` holds the current address; `instr_mem` combinationally returns the instruction at that address, using `pc_addr[31:2]` to convert the byte address into a word index |
| **2. Decode** | The instruction word is bit-sliced (`opcode`, `rd`, `funct3`, `rs1`, `rs2`, `funct7`) and fed into `control_unit`, `alu_control`, and `imm_gen` |
| **3. Register Read** | `register_file` returns `read_data1`/`read_data2`; `imm_gen` produces the sign-extended immediate, in parallel |
| **4. ALU-Source Select** | `alu_src_mux` picks the ALU's second operand — `read_data2` for `ADD`, or the immediate for `ADDI` — controlled by `ALUSrc` |
| **5. Execute** | `alu` computes the selected operation on `operand1`/`operand2` (operation chosen by `alu_control`'s `alu_opcode`, with `flag` selecting signed vs. unsigned comparison for `SLT`/`SLTU`) |
| **6. Write-Back** | The ALU's result is written into `register_file` at address `rd`, gated by `RegWrite`. `pc_reg` increments by `4` on the same edge, ready for the next fetch |

### R-type vs I-type — the one real difference

| | R-type (e.g. `ADD rd, rs1, rs2`) | I-type (e.g. `ADDI rd, rs1, imm`) |
|---|---|---|
| ALU operand 2 source | Register file (`rs2`) | Sign-extended immediate |
| `ALUSrc` | `0` | `1` |
| Everything else | **Identical** | **Identical** |

A single control bit (`ALUSrc`) reroutes one wire — the rest of the datapath doesn't need to know or care which instruction is executing. The same is true for `SLT` vs `SLTU`: a single bit (`flag`, derived from `funct3`) tells the ALU whether to compare `operand1`/`operand2` as signed or unsigned values — everything else about the two instructions is identical.

---

## 5. 🧩 How the Whole CPU Works — End-to-End Walkthrough

This section ties every module together by tracing **one real instruction, all the way through the hardware**, then zooming out to show how a short program runs back-to-back.

### 🔬 Tracing a single instruction: `add x3, x1, x2`

Assume `x1 = 5` and `x2 = 10` already sit in the register file (from the two `ADDI`s that ran before this one). Here is exactly what happens, module by module, in the one clock cycle this instruction takes to execute:

| Step | Module involved | What happens |
|---|---|---|
| ① | `pc_reg` | `pc_out = 8` (this is the 3rd instruction — byte address `8`, since each instruction is 4 bytes) |
| ② | `instr_mem` | `pc_addr[31:2]` = word index `2` → returns `mem[2] = 0x002081B3` on the `instruction` wire |
| ③ | Bit-slicing (inside `riscv_core`) | `opcode = 0110011`, `rd = 00011` (x3), `funct3 = 000`, `rs1 = 00001` (x1), `rs2 = 00010` (x2), `funct7 = 0000000` |
| ④ | `control_unit` | Sees `opcode = 0110011` → outputs `RegWrite = 1`, `ALUSrc = 0` |
| ⑤ | `alu_control` | Sees `opcode = 0110011`, `funct3 = 000`, `funct7 = 0000000` → outputs `alu_opcode = 000` (ADD); also outputs `flag = 0` (irrelevant here, only matters for `SLT`/`SLTU`) |
| ⑥ | `register_file` | Reads `rs1 = x1` → `read_data1 = 5`; reads `rs2 = x2` → `read_data2 = 10` |
| ⑦ | `imm_gen` | Also computes an immediate in parallel (`imm_out` = some value) — but it's irrelevant here, since... |
| ⑧ | `alu_src_mux` | `ALUSrc = 0` → passes `read_data2` (10) through as `operand2`, ignoring `imm_out` entirely |
| ⑨ | `alu` | Computes `operand1 + operand2` = `5 + 10` = **`15`**, using `alu_opcode = 000` (ADD) |
| ⑩ | `register_file` (write-back) | Because `RegWrite = 1`, on this same clock edge, `x3` is written with `alu_result = 15` |
| ⑪ | `pc_reg` | On the same clock edge, `pc_out` becomes `12`, pointing at the 4th instruction next |

**All eleven of those steps happen within a single clock cycle** — that's the entire point of a single-cycle design. Nothing here waits for a second clock edge; the moment the clock ticks, the whole chain above has already settled combinationally, and only `pc_reg`/`register_file` actually latch new values on that edge.

### 🎬 Running the full 22-instruction program, cycle by cycle

| Cycle | `pc_out` | Instruction | What it does | New register value |
|---|---|---|---|---|
| 1  | `0`  | `addi x1, x0, 5`   | `x1 = 0 + 5`       | `x1 = 5` |
| 2  | `4`  | `addi x2, x0, 10`  | `x2 = 0 + 10`      | `x2 = 10` |
| 3  | `8`  | `add  x3, x1, x2`  | `x3 = 5 + 10`      | `x3 = 15` |
| 4  | `12` | `addi x4, x3, -3`  | `x4 = 15 + (-3)`   | `x4 = 12` |
| 5  | `16` | `add  x5, x4, x4`  | `x5 = 12 + 12`     | `x5 = 24` |
| 6  | `20` | `addi x6, x0, -6`  | `x6 = 0 + (-6)`    | `x6 = -6` |
| 7  | `24` | `add  x7, x5, x6`  | `x7 = 24 + (-6)`   | `x7 = 18` |
| 8  | `28` | `sub  x8, x7, x6`  | `x8 = 18 - (-6)`   | `x8 = 24` |
| 9  | `32` | `and  x9, x7, x8`  | `x9 = 18 & 24`     | `x9 = 16` |
| 10 | `36` | `or   x10, x7, x8` | `x10 = 18 \| 24`   | `x10 = 26` |
| 11 | `40` | `xor  x11, x7, x8` | `x11 = 18 ^ 24`    | `x11 = 10` |
| 12 | `44` | `sltu x12, x7, x8` | `x12 = (18 <u 24)` | `x12 = 1` |
| 13 | `48` | `slt  x13, x7, x6` | `x13 = (18 <s -6)` | `x13 = 0` |
| 14 | `52` | `sll  x14, x12, x7`| `x14 = 1 << 18`    | `x14 = 262144` |
| 15 | `56` | `srl  x15, x14, x7`| `x15 = 262144 >> 18` | `x15 = 1` |
| 16 | `60` | `andi x16, x7, 16` | `x16 = 18 & 16`    | `x16 = 16` |
| 17 | `64` | `ori  x17, x7, 16` | `x17 = 18 \| 16`   | `x17 = 18` |
| 18 | `68` | `xori x18, x7, 16` | `x18 = 18 ^ 16`    | `x18 = 2` |
| 19 | `72` | `slli x19, x7, 2`  | `x19 = 18 << 2`    | `x19 = 72` |
| 20 | `76` | `srli x20, x19, 2` | `x20 = 72 >> 2`    | `x20 = 18` |
| 21 | `80` | `sltiu x21, x7, 2` | `x21 = (18 <u 2)`  | `x21 = 0` |
| 22 | `84` | `slti x22, x6, -2` | `x22 = (-6 <s -2)` | `x22 = 1` |

A few things worth noticing as you scan this table:

- **Cycles 1–5** are the original minimal proof-of-concept — `ADDI`-seeded constants combined with `ADD`, including a chained dependency (`x3` feeding `x4`) and a negative immediate.
- **Cycles 12 and 13** are the signed/unsigned pair discussed above — same source registers (`x7`, but compared against `x8` and `x6` respectively), completely different comparison logic invoked via `flag`.
- **Cycles 14–15** demonstrate `SLL` and `SRL` round-tripping a value — shifting `1` left by `18` and then right by `18` again — a good sanity check that both shift directions work correctly and agree with each other.
- **Cycles 16–21** exercise every I-type variant against the same operand (`x7 = 18`), making it easy to eyeball that each one matches its R-type counterpart's logic, just with an immediate instead of a second register.
- **Cycle 22** is the trickiest case in the whole program: comparing two *negative* numbers (`-6` and `-2`) with a *signed* comparison — easy to get backwards if sign-extension or `$signed()` casting is done incorrectly anywhere in the chain, which makes it a genuinely meaningful correctness check, not just a formality.

Notice how **`x1` = `x0 + 5` uses the exact same hardware path as `x3` = `x1 + x2`, which uses the exact same hardware path as `x9` = `x7 & x8`** — the only thing that changes cycle to cycle is which bits happen to be sitting in the instruction word, which flip `ALUSrc`/`alu_opcode`/`flag`, change which registers get read, and change what gets written where. There is no special-case circuitry for "the first instruction," "a constant-loading instruction," or "a logic instruction" — it's the same 11-step chain from the single-instruction trace above, repeated 22 times with different bits.

### 🔀 A closer look: `SLT` vs `SLTU` on the same bit pattern

To see exactly why the `flag` signal exists, imagine `x1` holds the bit pattern `0xFFFFFFFF` and `x2` holds `1`, and both `slt x3, x1, x2` and `sltu x4, x1, x2` run in sequence:

| Instruction | `funct3` | `flag` | Interpretation of `x1` | Result |
|---|---|---|---|---|
| `slt x3, x1, x2`  | `010` | `1` (signed) | `-1` | `x3 = 1` — because `-1 < 1` |
| `sltu x4, x1, x2` | `011` | `0` (unsigned) | `4294967295` | `x4 = 0` — because `4294967295 < 1` is false |

**Identical bits, identical `alu_opcode` (`101`), completely different results** — purely because `alu_control` derives `flag` from `funct3` and hands it to the ALU, which then chooses `$signed()` comparison or plain unsigned comparison accordingly.

### 🗺️ The big picture

Zooming all the way out, the whole CPU is really just **one combinational chain (fetch → decode → read → execute) sitting between two clocked memories** (`pc_reg` and `register_file`). Every cycle:

1. The two clocked elements present their *current* state (`pc_out`, and whatever's in the registers).
2. Everything in between computes new values from that state, combinationally, with no memory of its own.
3. On the next clock edge, the two clocked elements latch the *new* state (`pc_out + 4`, and the ALU's result into `rd`) — and the whole process repeats for the next instruction.

That's the entire mental model for a single-cycle CPU: **state lives only in `pc_reg` and `register_file`; everything else is just wires and logic gates recomputing an answer from scratch every cycle.**

---

## 6. 📁 Project Structure (File Hierarchy)

```
riscv-single-cycle-cpu/
│
├── register_file.v         # 32×32 register file (2 read ports, 1 write port, x0 = 0)
├── tb_register_file.v      # Standalone testbench — register_file.v
│
├── alu.v                   # ALU_RISCV — 8-operation combinational ALU
├── tb_alu.v                # Standalone testbench — alu.v
│
├── imm_gen.v               # Sign-extends the 12-bit I-type immediate to 32 bits
├── tb_imm_gen.v            # Standalone testbench — imm_gen.v
│
├── control_unit.v          # Decodes opcode → RegWrite, ALUSrc
├── tb_control_unit.v       # Standalone testbench — control_unit.v
│
├── alu_control.v           # Decodes opcode/funct3/funct7 → alu_opcode
├── tb_alu_control.v        # Standalone testbench — alu_control.v
│
├── pc_reg.v                # Program counter — resets to 0, increments by 4
├── tb_pc_reg.v             # Standalone testbench — pc_reg.v
│
├── instr_mem.v             # Combinational instruction memory (64 words)
├── tb_instr_mem.v          # Standalone testbench — instr_mem.v
│
├── alu_src_mux.v           # 2:1 mux — register value vs immediate, into the ALU
├── tb_alu_src_mux.v        # Standalone testbench — alu_src_mux.v
│
├── riscv_core.v            # 🔝 Top-level module — wires all 8 modules above together
├── tb_riscv_core.v         # 🔝 Full-system testbench — loads a program, checks results
│
├── schematic.pdf           # Full datapath schematic / block diagram
├── io_wave.png             # Exported waveform screenshot from GTKWave
├── console.png             # Terminal/console output screenshot from simulation
└── dump.vcd                # Waveform dump, generated after running any testbench
```

**Total: 22 files** — 9 core modules + 9 matching testbenches (18 files) + 4 supporting artifacts.

---

## 7. 📂 Module-by-Module Breakdown

### `pc_reg.v` — Program Counter

| Port | Direction | Width | Description |
|---|---|---|---|
| `pc_out` | output reg | 32-bit | Current program counter value |
| `rst` | input | 1-bit | Synchronous reset — sets PC to 0 |
| `clk` | input | 1-bit | Clock |

Resets to `0`; otherwise increments by **4** every rising edge (RISC-V is byte-addressed, each instruction is 4 bytes).

---

### `instr_mem.v` — Instruction Memory

| Port | Direction | Width | Description |
|---|---|---|---|
| `instruction` | output | 32-bit | Instruction word at `pc_addr` |
| `pc_addr` | input | 32-bit | Byte address from `pc_reg` |

Internally a `reg [31:0] mem [0:63]` array. `pc_addr[31:2]` drops the bottom 2 bits to convert a byte address into a word index. No `initial` block — the program is loaded externally by the testbench via hierarchical references, like real firmware pre-loaded into ROM before reset.

---

### `register_file.v` — 32×32 Register File

| Port | Direction | Width | Description |
|---|---|---|---|
| `read_data1` / `read_data2` | output | 32-bit | Values read from `rs1` / `rs2` |
| `write_data` | input | 32-bit | Value to write into `rd` |
| `rd` / `rs1` / `rs2` | input | 5-bit each | Register addresses |
| `RegWrite` | input | 1-bit | Write enable |
| `rst` | input | 1-bit | Synchronous reset — clears all 32 registers |
| `clk` | input | 1-bit | Clock |

Reads are combinational, writes are clocked. `x0` is hardwired to always read as `0`, regardless of what's stored internally — a strict RISC-V requirement.

---

### `imm_gen.v` — Immediate Generator

| Port | Direction | Width | Description |
|---|---|---|---|
| `imm_out` | output | 32-bit | Sign-extended immediate |
| `instruction` | input | 32-bit | Full instruction word |

`{{20{instruction[31]}}, instruction[31:20]}` — replicates the sign bit across the upper 20 bits, correctly handling both positive and negative immediates.

---

### `control_unit.v` — Main Control Unit

| Port | Direction | Width | Description |
|---|---|---|---|
| `RegWrite` | output | 1-bit | Enables register file write-back |
| `ALUSrc` | output | 1-bit | `0` = ALU operand2 from register, `1` = from immediate |
| `opcode` | input | 7-bit | `instruction[6:0]` |

`RegWrite = 1` for all 9 supported instructions (both R-type opcode `0110011` and I-type opcode `0010011`). `ALUSrc = 1` for I-type, `0` for R-type.

---

### `alu_control.v` — ALU Control

| Port | Direction | Width | Description |
|---|---|---|---|
| `alu_opcode` | output reg | 3-bit | Operation code fed to `alu` |
| `flag` | output | 1-bit | `1` = interpret `SLT`/`SLTI` as signed comparison, `0` = unsigned (`SLTU`/`SLTIU`) |
| `opcode` | input | 7-bit | Instruction opcode |
| `funct3` | input | 3-bit | Instruction funct3 field |
| `funct7` | input | 7-bit | Instruction funct7 field |

Maps every supported `funct3` (both R-type and I-type) to the matching `alu_opcode`. Disambiguates `ADD` vs `SUB` using `funct7`. `flag = (funct3 == 3'b010)` — true only for `SLT`/`SLTI`, false for `SLTU`/`SLTIU`, letting the ALU choose signed vs. unsigned comparison for the shared `alu_opcode = 101` slot. `SRA`/`SRAI` are not distinguished from `SRL`/`SRLI` — see the note in [Section 3](#3--instruction-encoding--r-type--i-type).

**`tb_alu_control.v` — its standalone testbench:** sweeps `funct3` through all 8 values (`000`–`111`) for the R-type opcode (`0110011`), including both `funct7` values (`0000000` and `0100000`) on the `000` case to confirm `ADD`/`SUB` disambiguation, then repeats the same 8-value sweep for the I-type opcode (`0010011`), and finally checks an unrecognized opcode (`0000000`) to confirm the `default` case correctly falls back to `alu_opcode = 000`. Every `(opcode, funct3, funct7)` combination this design actually needs to handle is exercised here, in isolation from the rest of the CPU.

---

### `alu.v` (module `ALU_RISCV`) — Arithmetic Logic Unit

| Port | Direction | Width | Description |
|---|---|---|---|
| `result` | output | 32-bit | Computation result |
| `operand1` / `operand2` | input | 32-bit each | ALU inputs |
| `alu_opcode` | input | 3-bit | Selects operation |
| `flag` | input | 1-bit | Selects signed (`1`) vs. unsigned (`0`) comparison for `alu_opcode = 101` |

| `alu_opcode` | Operation |
|---|---|
| `000` | ADD |
| `001` | SUB |
| `010` | AND |
| `011` | OR |
| `100` | XOR |
| `101` | SLT (signed, if `flag=1`) / SLTU (unsigned, if `flag=0`) |
| `110` | SLL |
| `111` | SRL |

All 8 opcode slots are used — `SLT` and `SLTU` share slot `101`, distinguished at compute-time by `flag` using Verilog's `$signed()` cast for the signed comparison. Every operation here is exercised by the supported instruction set.

**`tb_alu.v` — its standalone testbench (internally named `tb_ALU_RISC_V`):** drives a fixed pair of operands (`5` and `6`) through all 8 `alu_opcode` values in sequence with `flag = 0`, confirming each arithmetic/logic/shift operation independently of the rest of the datapath. A final test case switches `flag = 1` and feeds in two negative operands (`0x80000005` and `0x80000006`, both negative in two's-complement) through the `SLT` opcode specifically — checking that the signed comparison path correctly handles two negative numbers, not just a negative-vs-positive case, which is a stricter and more meaningful test than comparing against a positive number would be.

---

### `alu_src_mux.v` — ALU Operand-2 Selector

| Port | Direction | Width | Description |
|---|---|---|---|
| `operand2` | output | 32-bit | Selected ALU second operand |
| `read_data2` | input | 32-bit | Value from register file (`rs2`) |
| `imm_out` | input | 32-bit | Sign-extended immediate |
| `ALUsrc` | input | 1-bit | Select line from `control_unit` |

The 2:1 mux that implements the entire R-type vs. I-type distinction for every instruction this core supports.

---

### `riscv_core.v` — Top-Level Core 🔝

| Port | Direction | Width | Description |
|---|---|---|---|
| `pc_out` | output | 32-bit | Current program counter value, exposed for synthesis and debug visibility |
| `rst` | input | 1-bit | Global reset |
| `clk` | input | 1-bit | Global clock |

> 🛠️ `pc_out` is a real output port (traced back through `pc_reg`), not just an internal wire — this keeps the whole datapath provably "alive" during Vivado synthesis. Without at least one real output, Vivado's `opt_design` optimizes the entire design away as dead logic (see [Design Decisions](#17--key-design-decisions)).

**Internal instance names** (used by the testbench for hierarchical inspection):

| Module | Instance name |
|---|---|
| `pc_reg` | `A1` |
| `instr_mem` | `A2` |
| `imm_gen` | `A3` |
| `control_unit` | `A4` |
| `register_file` | `A5` |
| `alu_src_mux` | `A6` |
| `alu_control` | `A7` |
| `alu` (`ALU_RISCV`) | `A8` |

Contains no logic of its own — purely instantiation, wiring, and instruction-field bit-slicing.

---

### `tb_riscv_core.v` — Full-System Testbench 🔝

Instantiates `riscv_core` with all 3 ports connected (`pc_out, rst, clk`). Generates the clock, pulses reset, hand-loads the 22-instruction test program directly into `instr_mem` (`uut.A2.mem[...]`), lets the CPU run for enough cycles to complete the whole program, then reads back and displays every register's final value (`uut.A5.Reg[...]`) — using `$signed(...)` where a negative result is expected — to verify correctness against the values in [Section 8](#8--test-program-used-for-verification).

---

## 8. 🧪 Test Program Used for Verification

The full-system testbench runs a 22-instruction program that exercises every one of the 9 supported operations, in both R-type and I-type form, including a chained dependency, a negative immediate, and both signed and unsigned comparisons:

```asm
addi  x1,  x0, 5        # x1 = 5
addi  x2,  x0, 10       # x2 = 10
add   x3,  x1, x2       # x3 = 15
addi  x4,  x3, -3       # x4 = 12   (negative immediate)
add   x5,  x4, x4       # x5 = 24
addi  x6,  x0, -6       # x6 = -6
add   x7,  x5, x6       # x7 = 18
sub   x8,  x7, x6       # x8 = 24
and   x9,  x7, x8       # x9 = 16
or    x10, x7, x8       # x10 = 26
xor   x11, x7, x8       # x11 = 10
sltu  x12, x7, x8       # x12 = 1    (unsigned compare)
slt   x13, x7, x6       # x13 = 0    (signed compare)
sll   x14, x12, x7      # x14 = 262144
srl   x15, x14, x7      # x15 = 1
andi  x16, x7, 16       # x16 = 16
ori   x17, x7, 16       # x17 = 18
xori  x18, x7, 16       # x18 = 2
slli  x19, x7, 2        # x19 = 72
srli  x20, x19, 2       # x20 = 18
sltiu x21, x7, 2        # x21 = 0
slti  x22, x6, -2       # x22 = 1    (negative vs. negative, signed)
```

| Instruction | Hex encoding | Instruction | Hex encoding |
|---|---|---|---|
| `addi x1, x0, 5`   | `0x00500093` | `sltu x12, x7, x8`  | `0x0083B633` |
| `addi x2, x0, 10`  | `0x00A00113` | `slt x13, x7, x6`   | `0x0063A6B3` |
| `add x3, x1, x2`   | `0x002081B3` | `sll x14, x12, x7`  | `0x00761733` |
| `addi x4, x3, -3`  | `0xFFD18213` | `srl x15, x14, x7`  | `0x007757B3` |
| `add x5, x4, x4`   | `0x004202B3` | `andi x16, x7, 16`  | `0x0103F813` |
| `addi x6, x0, -6`  | `0xFFA00313` | `ori x17, x7, 16`   | `0x0103E893` |
| `add x7, x5, x6`   | `0x006283B3` | `xori x18, x7, 16`  | `0x0103C913` |
| `sub x8, x7, x6`   | `0x40638433` | `slli x19, x7, 2`   | `0x00239993` |
| `and x9, x7, x8`   | `0x0083F4B3` | `srli x20, x19, 2`  | `0x0029DA13` |
| `or x10, x7, x8`   | `0x0083E533` | `sltiu x21, x7, 2`  | `0x0023BA93` |
| `xor x11, x7, x8`  | `0x0083C5B3` | `slti x22, x6, -2`  | `0xFFE32B13` |

This program exercises: basic `ADDI` constant loading via `x0`, register-to-register `ADD`, chained data dependencies, negative-immediate sign-extension, all 9 R-type ALU operations, all 8 I-type immediate operations, and — critically — **both `SLT` (signed) and `SLTU` (unsigned)** producing different results from the same bit patterns (`x7`/`x8` at instructions 12–13), proving the `flag` signal correctly selects `$signed()` vs. plain comparison inside the ALU.

---

## 9. 📥 How to Download This Project

1. Go to the repository's GitHub page.
2. Click the green **`<> Code`** button near the top right.
3. Click **Download ZIP**.
4. Once downloaded, right-click the `.zip` file → **Extract All...** → choose a folder (e.g. `C:\Projects\riscv-single-cycle-cpu`).

Alternatively, if you have Git installed on Windows (via [Git for Windows](https://git-scm.com/download/win)):

```bash
git clone https://github.com/<your-username>/riscv-single-cycle-cpu.git
cd riscv-single-cycle-cpu
```

---

## 10. 🪟 How to Run on Windows

### Step 1 — Install VS Code

1. Download from [code.visualstudio.com](https://code.visualstudio.com/) and run the installer.
2. During install, check **"Add to PATH"** if prompted.
3. *(Optional but recommended)* Install the **Verilog-HDL/SystemVerilog** extension from the Extensions marketplace (`Ctrl+Shift+X` → search "Verilog") for syntax highlighting.

### Step 2 — Install Icarus Verilog

1. Go to [bleyer.org/icarus](http://bleyer.org/icarus/) and download the latest Windows installer (`iverilog-vX.X-X-setup.exe`).
2. Run the installer.
3. ⚠️ **Important:** on the installation screen, make sure the checkbox **"Add Icarus Verilog to PATH"** (or similar wording) is ticked — this lets you run `iverilog` and `vvp` from any terminal without extra setup.
4. GTKWave is bundled with this same installer — no separate download needed.
5. Verify the install by opening **Command Prompt** or **PowerShell** and typing:
   ```bash
   iverilog -v
   ```
   You should see version information printed, not a "command not found" error.

### Step 3 — Open the project folder in VS Code

1. Open VS Code.
2. **File → Open Folder...** → select the extracted/cloned `riscv-single-cycle-cpu` folder.
3. Open a terminal inside VS Code: **Terminal → New Terminal** (or `` Ctrl+` ``). This opens a terminal already pointed at your project folder.

### Step 4 — Compile the full-system testbench

In the VS Code terminal (PowerShell or Command Prompt), run:

```bash
iverilog -o tb_riscv_core.out tb_riscv_core.v riscv_core.v pc_reg.v instr_mem.v register_file.v imm_gen.v control_unit.v alu_control.v alu_src_mux.v alu.v
```

If this produces no errors, a file named `tb_riscv_core.out` appears in your folder.

### Step 5 — Run the simulation

```bash
vvp tb_riscv_core.out
```

This prints the `$display`/`$monitor` output to your terminal and generates a `dump.vcd` file in the same folder.

### Step 6 — View the waveform in GTKWave

```bash
gtkwave dump.vcd
```

This opens the GTKWave window. In the **SST** panel on the left, click `tb_riscv_core`, then double-click signals (e.g. `clk`, `rst`, `uut.pc_out`, `uut.instr`) to add them to the waveform viewer.

> 💡 **To test one module in isolation** (e.g. just the ALU), compile its matching testbench instead of the full core:
> ```bash
> iverilog -o tb_alu.out tb_alu.v alu.v
> vvp tb_alu.out
> ```

### Step 7 (Optional) — Using Xilinx Vivado on Windows

1. Download and install **Vivado** (Windows native installer) from the Xilinx/AMD website — the free **WebPACK** edition is enough for this project.
2. Open Vivado → **Create Project** → choose **RTL Project**.
3. **Add Sources** → add all 9 `.v` module files as **Design Sources** (do **not** include the testbenches here).
4. Add `tb_riscv_core.v` separately as a **Simulation Source** (*Add Sources* → *Add or Create Simulation Sources*).
5. In the **Sources** panel, right-click `tb_riscv_core` → **Set as Top** (for simulation).
6. **Flow Navigator → Simulation → Run Behavioral Simulation.**
7. Use Vivado's built-in waveform viewer — add `clk`, `rst`, `uut/pc_out`, `uut/instr`, and `uut/A5/Reg[1]` through `Reg[22]`.
8. *(Optional, for synthesis)* Set `riscv_core` (not the testbench) as **Top** for synthesis, then run **Synthesis → Implementation** from the Flow Navigator.

---

## 11. 🐧🍎 How to Run on macOS / Linux

**Install (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install iverilog gtkwave
```

**Install (macOS, Homebrew):**
```bash
brew install icarus-verilog gtkwave
```

**Compile, run, and view** (same commands as Windows, once installed):
```bash
iverilog -o tb_riscv_core.out tb_riscv_core.v riscv_core.v pc_reg.v instr_mem.v register_file.v imm_gen.v control_unit.v alu_control.v alu_src_mux.v alu.v
vvp tb_riscv_core.out
gtkwave dump.vcd
```

---

## 12. 🖥️ Sample Simulation Output

```
---- Final Register Values ----
x1 = 5  (expected 5)
x2 = 10 (expected 10)
x3 = 15 (expected 15)
x4 = 12 (expected 12)
x5 = 24 (expected 24)
x6 = -6 (expected -6)
x7 = 18 (expected 18)
x8 = 24 (expected 24)
x9 = 16 (expected 16)
x10 = 26 (expected 26)
x11 = 10 (expected 10)
x12 = 1 (expected 1)
x13 = 0 (expected 0)
x14 = 262144 (expected 262144)
x15 = 1 (expected 1)
x16 = 16 (expected 16)
x17 = 18 (expected 18)
x18 = 2 (expected 2)
x19 = 72 (expected 72)
x20 = 18 (expected 18)
x21 = 0 (expected 0)
x22 = 1 (expected 1)
--- all tests passed ---
```

📸 See `console.png` for the terminal output shown above as an actual screenshot, `io_wave.png` for the corresponding GTKWave waveform, and `schematic.pdf` for the full block-level datapath diagram.

---

## 13. 🐞 Debugging Journey — Bugs Found & Fixed

This project wasn't written correctly on the first attempt — nothing hand-built ever is. Every module went through a write → review → fix → re-verify cycle before being finalized. Documenting the real bugs (not just the final clean code) is deliberate: these are exactly the mistakes anyone hand-writing Verilog for the first time is likely to make, and recognizing the *pattern* behind each one is more useful than just seeing correct code.

### 🔴 Bug 1 — `output reg` vs. `assign` mismatch

**Symptom:** Compile error.
**Cause:** A port declared as `output reg [31:0] read_data1` was then driven with a continuous `assign read_data1 = ...` statement. `assign` can only drive a `wire`, never a `reg` — this is a hard rule, not a style preference.
**Fix:** If a signal is driven by `assign` (combinational, no clock), declare it as a plain `output` (implicitly `wire`). If a signal is driven inside an `always` block, declare it `output reg`. The two assignment styles and the two declaration styles must match.
**Where it showed up:** `register_file.v` (read ports), `pc_reg.v` (in reverse — `pc_out` needed to *become* `reg` once it was assigned inside a clocked `always` block).

### 🔴 Bug 2 — Case-sensitive typos creating phantom signals

**Symptom:** Compile error, or a silently disconnected/undriven signal.
**Cause:** Verilog is case-sensitive and does not require declaring every identifier before first use in older toolchains — a typo like `Write_data` instead of `write_data`, or `oprand1` instead of `operand1`, doesn't always throw an obvious "undefined" error. Instead, it can silently create a brand-new, unrelated 1-bit wire with that exact misspelled name, completely disconnected from the port it was meant to reference.
**Fix:** No shortcut here beyond careful, deliberate line-by-line comparison between the port list and every place a signal name is used inside the module body. This bug is exactly why the module names were reviewed character-by-character during development, rather than just checked for "does it look about right."
**Where it showed up:** `register_file.v` (`Write_data` vs `write_data`), `ALU_RISCV` (`oprand1`/`oprand2` vs `operand1`/`operand2`).

### 🔴 Bug 3 — Malformed replication operator

**Symptom:** Compile error.
**Cause:** `{20{1'b1}, instruction[31:20]}` — the replication operator `{N{value}}` needs its own enclosing braces *nested inside* the outer concatenation braces. Writing `{20{1'b1}, ...}` (missing the closing brace on the inner replication) is a syntax error.
**Fix:** `{{20{1'b1}}, instruction[31:20]}` — note the doubled `{{`. Even better: since the fill bit and the sign bit are the same value, `{{20{instruction[31]}}, instruction[31:20]}` sign-extends correctly in one line without a ternary at all.
**Where it showed up:** `imm_gen.v`, during the first draft of sign-extension logic.

### 🔴 Bug 4 — `x0` not actually hardwired to zero

**Symptom:** No compile error — silently wrong simulation results whenever register `x0` is read.
**Cause:** The RISC-V spec requires `x0` to *always* read as `0`, but nothing in a naive register-file implementation enforces this automatically. Internal storage (`Reg[0]`) can still be written to and would read back whatever was last written, unless explicitly overridden.
**Fix:** Force the read path itself, not the write path: `assign read_data1 = (rs1 == 5'b0) ? 32'b0 : Reg[rs1];`. This guarantees correctness regardless of what happens to `Reg[0]` internally — simpler and more robust than trying to block the write.
**A related typo that appeared mid-fix:** the condition was accidentally written to check `rst` (the reset signal) instead of `rs1`/`rs2` (the register *address* being read) — an easy mistake since both are short, similarly-positioned identifiers. The fix must check the *address*, not the *reset state*.

### 🔴 Bug 5 — Blocking (`=`) vs. non-blocking (`<=`) assignment, used backwards

**Symptom:** No compile error — but a correctness/simulation-semantics bug that can behave inconsistently across simulators.
**Cause:** Verilog has two assignment operators with different scheduling semantics, and each is meant for a specific kind of `always` block:

| Block type | Correct operator | Wrong operator used (bug) |
|---|---|---|
| `always @(posedge clk)` — sequential/clocked | `<=` (non-blocking) | `=` (blocking) — used in `pc_reg.v`'s first draft |
| `always @(*)` — combinational | `=` (blocking) | `<=` (non-blocking) — used in `alu_control.v`'s first draft |

**Fix:** Match the operator to the block type, every time, with no exceptions. This is one of the few Verilog conventions that isn't just stylistic — mixing them backwards can produce race conditions or simulator-dependent results that only show up under certain timing conditions, making it a genuinely dangerous bug to leave in place even if it happens to "work" in one particular simulator.

### 🔴 Bug 6 — Testbench race condition between two `initial` blocks

**Symptom:** Simulator-dependent, unpredictable initial signal values.
**Cause:** Two separate `initial` blocks both attempting to set the same signal (`clk`/`rst`) at simulation time `0`. Verilog does not guarantee execution order *between* separate `initial` blocks that start at the same instant — only that each individual block executes its own statements in order.
**Fix (general rule):** Prefer a single `initial` block for anything that must happen in a specific order relative to other setup steps. In this project's final testbench, the two `initial` blocks were deliberately kept (per a specific design choice), but only because they don't actually contend over the same signal at the same instant — `clk`/`rst` initialization in one block, and `mem[...]` loading plus the reset pulse sequence in the other, with no overlapping writes at time `0`.

### 🔴 Bug 7 — Loading the instruction program *after* releasing reset

**Symptom:** The first one or two instructions execute using garbage (`x`, unknown) data, even though later instructions run correctly.
**Cause:** The testbench released `rst` (`rst = 1'b0`) and let the clock advance the PC *before* the `uut.A2.mem[...] = ...` lines had executed. Since `pc_reg` only holds the PC at `0` while `rst` is actively high, releasing reset early means the first post-reset clock edge fetches from instruction memory that hasn't been populated yet.
**Fix:** Ensure every `mem[...]` write completes *while `rst` is still asserted* — reset can be asserted first (that's harmless, since the PC just holds at 0 the whole time), but it must not be *released* until after the full program is loaded. This mirrors how real hardware works: firmware exists in ROM/flash before power-on, not something written in after the reset button is released.

### 🔴 Bug 8 — `%0d` printing negative registers as huge unsigned numbers

**Symptom:** `$display("%0d", uut.A5.Reg[6])` printed `4294967290` instead of the expected `-6`.
**Cause:** `Reg` is declared `reg [31:0]` — plain, unsigned by default in Verilog. `$display`'s `%d` format specifier only prints a value as signed if the *variable itself* is declared `signed`; it has no way to infer "this bit pattern is meant to represent a negative number" on its own.
**Fix:** Wrap the read in `$signed(...)` at the point of display: `$display("%0d", $signed(uut.A5.Reg[6]));`. This doesn't change any bits — it just tells `$display` to interpret the existing bit pattern as two's-complement signed. The same technique is needed *inside* the ALU itself (not just at display time) for `SLT`'s actual comparison logic, since `operand1 < operand2` on plain `input [31:0]` wires performs an unsigned comparison regardless of what the values are "supposed to" represent.

### 🔴 Bug 9 — `SLT` computing an unsigned comparison despite its name

**Symptom:** No compile error — silently wrong result for `SLT` whenever one operand's sign bit was set (i.e., whenever the two's-complement interpretation differs from the unsigned interpretation).
**Cause:** Direct extension of Bug 8's root cause, but inside actual computation rather than just display: `operand1 < operand2` on unsigned wires always performs an unsigned comparison, even for the opcode meant to represent *signed* less-than.
**Fix:** Split into two genuinely different code paths, selected by a new `flag` signal (derived in `alu_control` from `funct3 == 3'b010`, since `SLT`'s `funct3` differs from `SLTU`'s): `flag ? ($signed(operand1) < $signed(operand2)) : (operand1 < operand2)`. This also revealed that a 3-bit `alu_opcode` (8 slots) was already fully used by the original 8 operations, so `SLT` and `SLTU` had to be designed to *share* one opcode slot (`101`) rather than each getting a dedicated one — solved by letting `flag` act as a secondary selector within that shared slot.

### 🔴 Bug 10 — Vivado `place_design` error: "The design is empty"

**Symptom:** Behavioral simulation works perfectly, but running Synthesis/Implementation in Vivado produces `[Place 30-494] The design is empty` and `[Common 17-69] Placer could not place all instances`.
**Cause:** `riscv_core`'s original port list was just `(rst, clk)` — no outputs at all. During simulation, hierarchical references (e.g. `uut.A5.Reg[1]`) can see straight through the module hierarchy regardless of ports — but synthesis only cares about physical pins. Since nothing internal to `riscv_core` ever reached an actual output port, Vivado's `opt_design` step correctly (from its own perspective) concluded that *none* of the internal logic could ever affect anything observable outside the chip, and optimized the entire design away as dead logic.
**Fix:** Add at least one real output port that's genuinely driven by internal logic — `pc_out`, wired via `assign pc_out = w1;` tracing back through `pc_reg`, was sufficient to keep that specific chain of logic alive during synthesis. (Note: this doesn't automatically protect *every* internal signal from removal — only the logic that provably feeds an exposed output is guaranteed to survive `opt_design`. For a design meant to actually target real FPGA hardware, more outputs would likely be needed; for this project, since only simulation is required, adding `pc_out` was enough to resolve the specific error encountered.)

---

## 14. 📘 Verilog Concepts Reference

A condensed reference of the Verilog rules and patterns this project leans on repeatedly. Useful as a refresher, or as a starting point if you're reading the module code for the first time.

### Combinational vs. sequential logic

| | Combinational | Sequential (clocked) |
|---|---|---|
| Trigger | `always @(*)` | `always @(posedge clk)` |
| Assignment operator | `=` (blocking) | `<=` (non-blocking) |
| Represents | Logic gates — output recomputed instantly from current inputs | A register — holds a value until explicitly told to update |
| Used in this project for | `alu`, `alu_control`, `control_unit`, `imm_gen`, `alu_src_mux`, `instr_mem`'s read path | `pc_reg`, `register_file`'s write path |

### `output` vs. `output reg`

- If a port is driven with a continuous `assign` statement anywhere in the module → declare it as plain `output` (a `wire` by default).
- If a port is driven inside an `always` block (either kind) → declare it `output reg`.
- `reg` in Verilog does **not** mean "this is a hardware register/flip-flop" — it just means "this signal is assigned inside a procedural block (`always`/`initial`)." A `reg` driven only inside a combinational `always @(*)` block still synthesizes to plain logic gates, not a flip-flop.

### Sign-extension with the replication operator

```verilog
{{20{instruction[31]}}, instruction[31:20]}
```

Reads as: take `instruction[31]` (the sign bit), repeat it `20` times, then concatenate the original 12-bit field after it — producing a 32-bit sign-extended value. The doubled `{{` is required syntax: the inner `{N{value}}` is the replication operator, and it must sit inside the outer `{...}` concatenation braces.

### `$signed()` — interpreting bits as signed without changing them

Verilog's `reg`/`wire` types are unsigned by default. `$signed(some_value)` doesn't modify any bits — it's a cast that tells the surrounding expression (a comparison, an arithmetic operation, or a `$display` format specifier) to interpret the existing bit pattern as two's-complement signed. Needed anywhere a genuinely signed comparison or signed display is required on a plain unsigned-declared variable — as opposed to declaring the variable itself `signed`, which would apply everywhere that variable is used, not just at one specific point.

### Hierarchical references — simulation-only visibility

Any signal or internal array declared inside a module remains reachable from a testbench sitting above it in the instantiation hierarchy, by chaining instance names with dots — regardless of whether that signal is a top-level port:

```verilog
uut.A2.mem[0] = 32'h00500093;      // poke a value into instr_mem's internal array
$display("%0d", uut.A5.Reg[6]);    // read a value out of register_file's internal array
```

This only works in **simulation** — it's a debugging/testbench convenience, not something synthesizable hardware can do. Real silicon can only be probed at its actual physical pins, which is precisely why `riscv_core` needed a real output port for *synthesis* (Bug 10 above) even though hierarchical references made that unnecessary for *simulation*.

### Positional vs. named port connections

```verilog
// Positional — order must exactly match the module's port declaration order
riscv_core uut (pc_out, rst, clk);

// Named — order doesn't matter, but every name must exactly match the module's port names
riscv_core uut (.pc_out(pc_out), .rst(rst), .clk(clk));
```

Positional connections are shorter but fragile — adding, removing, or reordering a module's ports silently breaks every positional instantiation elsewhere, with no compiler error if the widths happen to still line up. Named connections are more verbose but immune to that entire class of bug, and are generally the safer choice once a module's port list is likely to change.

### `%d` vs `%h` vs `%b` in `$display`/`$monitor`

| Specifier | Prints |
|---|---|
| `%b` | Raw binary |
| `%h` | Raw hexadecimal |
| `%d` | Decimal — **unsigned**, unless the value is wrapped in `$signed(...)` or the variable itself is declared `signed` |

`%h` and `%b` are "honest" in the sense that they show the literal bits with no interpretation — `%d` is the one that requires you to think about signedness explicitly.

---

## 15. 📖 Glossary of Terms

| Term | Meaning |
|---|---|
| **RISC** | Reduced Instruction Set Computer — small set of simple, fixed-length instructions |
| **CISC** | Complex Instruction Set Computer — larger set of variable-length, more capable instructions |
| **ISA** | Instruction Set Architecture — the contract between hardware and software: which instructions exist and what they do |
| **RV32I** | The 32-bit base integer instruction set of RISC-V — the mandatory minimum every RISC-V CPU must implement |
| **Opcode** | The lowest 7 bits of an instruction — identifies its broad category/format (R-type, I-type, etc.) |
| **funct3** | A 3-bit field that further narrows down which specific operation within an opcode's category is meant |
| **funct7** | A 7-bit field (R-type only) that disambiguates operations sharing the same opcode and funct3 (e.g. `ADD` vs `SUB`) |
| **Immediate (`imm`)** | A constant value encoded directly into the instruction word itself, rather than read from a register |
| **Sign extension** | Extending a smaller signed value to a wider bit-width by replicating its sign bit into the new upper bits, preserving its numeric value |
| **Two's complement** | The standard binary representation for signed integers, where negation is computed by inverting all bits and adding 1 |
| **Register file** | The small, fast bank of general-purpose registers (32 of them, `x0`–`x31`, in RV32I) a CPU operates on |
| **`x0` / zero register** | A register hardwired to always read as `0`, regardless of what's written to it — used as a source of the constant zero |
| **Datapath** | The collection of hardware (registers, ALU, muxes, wires) that data actually flows through during execution |
| **Control logic / control unit** | The hardware that decodes instructions and generates the signals steering the datapath (which mux input to select, whether to write, etc.) |
| **Single-cycle CPU** | A CPU design where every instruction fully completes — fetch through write-back — within one clock cycle |
| **Combinational logic** | Logic whose output depends only on its current inputs, with no memory of past states (e.g. an adder, a mux) |
| **Sequential logic** | Logic that has memory — its output depends on current inputs *and* stored state, updated only on clock edges (e.g. a register) |
| **Write-back** | The final stage of instruction execution, where a computed result is stored into the register file |
| **Hierarchical reference** | In simulation, a dotted path (`top.instance.signal`) used to directly access a signal buried inside nested module instances |
| **Testbench** | A non-synthesizable simulation-only module that drives inputs into a design and checks its outputs, used purely for verification |
| **Synthesis** | The process of translating Verilog RTL code into an actual gate-level (or FPGA-primitive-level) hardware implementation |
| **`opt_design` / `place_design`** | Vivado's optimization and physical-placement stages during Implementation — distinct from, and stricter than, simulation |

---

## 16. 🚧 Current Limitations & Roadmap

This project is **feature-complete for its intended scope** — all 9 ALU operations (R-type and I-type) are implemented, tested, and passing. It is **not** planned to grow further as part of this version. Documented here for anyone who wants to fork and extend it:

- ⛔ `SRA`/`SRAI` — **intentionally excluded**, not a missing feature (see [Design Decisions](#17--key-design-decisions))
- 🔭 `LOAD`/`STORE` support — would require a data memory module and `MemRead`/`MemWrite`/`MemtoReg` control signals
- 🔭 Branch instructions (`BEQ`, `BNE`, etc.) — would require a branch comparator and PC-relative addressing
- 🔭 `LUI`/`AUIPC`/`JAL`/`JALR` — would require U-type/J-type immediate decoding and PC write-back paths
- 🔭 Pipelining and hazard handling — would only become relevant if this evolved beyond a single-cycle design

The 🔭 items are **not planned** — they're left here only as a reference for what a further extension would involve, should this design be picked up again or forked.

---

## 17. 🔑 Key Design Decisions

**Single-cycle instead of a shared-bus multi-cycle design.** Matches how RV32I's fixed-length, cleanly-fielded format is meant to be used — every instruction fully executes in one clock edge, with no bus arbitration needed.

**Separate `control_unit` and `alu_control`.** Mirrors real CPU design practice — datapath-wide signals versus ALU-specific operation selection — keeping each module focused and easy to extend independently.

**`x0` hardwired at the read output, not blocked at the write.** `(rs1 == 0) ? 0 : Reg[rs1]` guarantees correctness regardless of what happens internally to `Reg[0]`.

**Unused ALU operations included now.** Zero cost today, and extending the instruction set later becomes purely a `control_unit`/`alu_control` change.

**`imm_gen` as its own module.** Keeps sign-extension logic isolated and independently testable, and mirrors how a real RV32I core needs separate immediate-generation logic per instruction format.

---

## 18. 👤 Author

Built module-by-module, bug-by-bug, from a blank file to a working RISC-V core — every line reviewed, debugged, and understood along the way rather than copy-pasted. 🛠️

Feel free to fork, ⭐ star, and extend this with more of the RV32I instruction set. Pull requests and issues welcome!

---





## 19. 📄 License

MIT License — free to use, modify, and distribute with attribution.
