## RV32I Single-Cycle RISC-V CPU 

A minimal single-cycle 32-bit RISC-V (RV32I) CPU built from scratch in Verilog HDL, executing ADD and ADDI. Fully modular datapath — PC, instruction memory, register file, ALU, control unit, ALU control, immediate generator, and ALU-source mux — each with its own testbench, simulated in Icarus Verilog and visualized in GTKWave & Vivado. 🚀

# 🧠 RV32I Single-Cycle RISC-V CPU — Self-Checking Verification Edition

### Built from scratch in Verilog HDL

> ⚙️ A fully modular, single-cycle 32-bit RISC-V processor, hand-built in Verilog HDL from the ground up — implementing 9 core ALU operations from the RV32I base integer instruction set, in both R-type and I-type form. Verified by a **self-checking testbench** with a live instruction-memory interface and a debug address-override port, rather than a one-shot "load a program and eyeball the final registers" test. Simulated with Icarus Verilog, inspected in GTKWave, and synthesizable in Xilinx Vivado. 🚀

> ✅ **Status:** Feature-complete for its scope. All 9 ALU operations (R-type + I-type), the register file, the full single-cycle datapath, and a 25-step self-checking regression suite are implemented and passing. `SRA`/`SRAI`, loads/stores, real branch/jump instructions, and pipelining are deliberately out of scope for this version — see [Roadmap](#17--current-limitations--roadmap).

---

## 📑 Table of Contents

1. [Project Highlights](#1--project-highlights)
2. [RISC-V, RISC vs CISC, and RV32I](#2--risc-v-risc-vs-cisc-and-rv32i)
3. [Instruction Encoding — R-type & I-type](#3--instruction-encoding--r-type--i-type)
4. [How the Single-Cycle Pipeline Works](#4--how-the-single-cycle-pipeline-works)
5. [The Self-Checking Testbench Architecture](#5--the-self-checking-testbench-architecture)
6. [How the Whole CPU Works — End-to-End Walkthrough](#6--how-the-whole-cpu-works--end-to-end-walkthrough)
7. [Project Structure (File Hierarchy)](#7--project-structure-file-hierarchy)
8. [Module-by-Module Breakdown](#8--module-by-module-breakdown)
9. [Testbenches — Self-Checking Suite & Standalone Unit Tests](#9--testbenches--self-checking-suite--standalone-unit-tests)
10. [Verification Program — All 25 Test Steps](#10--verification-program--all-25-test-steps)
11. [How to Download This Project](#11--how-to-download-this-project)
12. [How to Run on Windows](#12--how-to-run-on-windows)
13. [How to Run on macOS / Linux](#13--how-to-run-on-macos--linux)
14. [Sample Simulation Output](#14--sample-simulation-output)
15. [Debugging Journey — Bugs Found & Fixed](#15--debugging-journey--bugs-found--fixed)
16. [Verilog Concepts Reference](#16--verilog-concepts-reference)
17. [Current Limitations & Roadmap](#17--current-limitations--roadmap)
18. [Key Design Decisions](#18--key-design-decisions)
19. [Glossary of Terms](#19--glossary-of-terms)
20. [Author](#20--author)
21. [License](#21--license)

---

## 1. 📌 Project Highlights

- ✅ Fully working **single-cycle 32-bit RISC-V datapath**, built entirely from first principles, no vendor IP
- ✅ **9 ALU operations** — `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SLT`, `SLTU`, `SRL` — in both R-type and I-type form
- ✅ **10 independent hardware modules**, each with its own dedicated testbench (20 files total)
- ✅ **Self-checking testbench**: every test step supplies inputs and an expected result, compares with `!==` (catching `X`/`Z`, not just value mismatches), and prints an automatic pass/fail summary — no manual waveform inspection required to know if something broke
- ✅ **Live instruction-memory interface** — instructions are written directly into `instr_mem` through real `address`/`number` ports during simulation, rather than only through hierarchical testbench pokes
- ✅ **Debug address-override port** (`jump`) — lets the testbench fetch and check any arbitrary instruction-memory address on demand, without disturbing the CPU's normal sequential program counter
- ✅ Working **32×32 register file** with `x0` hardwired to zero on **both** the read path and the write path
- ✅ Signed **and** unsigned comparison (`SLT` vs `SLTU`) correctly distinguished via a dedicated `flag` signal and `$signed()` casting
- ✅ Proper **sign-extended immediate generation**, tested against negative immediates and negative-vs-negative signed comparisons
- ✅ Clean separation of **control logic**, **address selection**, and the **datapath** — each is its own module
- ✅ 25-step regression suite covering all 9 ALU operations, chained data dependencies, negative numbers, and the debug address-override mechanism — all passing
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

Every RISC-V instruction is a fixed **32 bits wide**. Every instruction this core supports uses one of these two formats:

**R-type**

```
 31        25 24     20 19     15 14    12 11      7 6        0
┌────────────┬─────────┬─────────┬────────┬──────────┬─────────┐
│   funct7   │   rs2   │   rs1   │ funct3 │    rd    │  opcode │
└────────────┴─────────┴─────────┴────────┴──────────┴─────────┘
```

**I-type**

```
 31                  20 19     15 14    12 11      7 6        0
┌──────────────────────┬─────────┬────────┬──────────┬─────────┐
│      imm[11:0]       │   rs1   │ funct3 │    rd    │  opcode │
└──────────────────────┴─────────┴────────┴──────────┴─────────┘
```

**Full encoding table for every instruction this core supports:**

| Instruction | opcode | funct3 | funct7 | `alu_opcode` | `flag` |
|---|---|---|---|---|---|
| `ADD`   | `0110011` | `000` | `0000000` | `000` | — |
| `SUB`   | `0110011` | `000` | `0100000` | `001` | — |
| `SLL`   | `0110011` | `001` | `0000000` | `110` | — |
| `SLT`   | `0110011` | `010` | `0000000` | `101` | `1` (signed) |
| `SLTU`  | `0110011` | `011` | `0000000` | `101` | `0` (unsigned) |
| `XOR`   | `0110011` | `100` | `0000000` | `100` | — |
| `SRL`   | `0110011` | `101` | `0000000` | `111` | — |
| `OR`    | `0110011` | `110` | `0000000` | `011` | — |
| `AND`   | `0110011` | `111` | `0000000` | `010` | — |
| `ADDI`  | `0010011` | `000` | — | `000` | — |
| `SLLI`  | `0010011` | `001` | — | `110` | — |
| `SLTI`  | `0010011` | `010` | — | `101` | `1` (signed) |
| `SLTIU` | `0010011` | `011` | — | `101` | `0` (unsigned) |
| `XORI`  | `0010011` | `100` | — | `100` | — |
| `SRLI`  | `0010011` | `101` | — | `111` | — |
| `ORI`   | `0010011` | `110` | — | `011` | — |
| `ANDI`  | `0010011` | `111` | — | `010` | — |

> 🧾 **Sign extension:** the 12-bit `imm[11:0]` field is extended to 32 bits by replicating bit `[31]` of the instruction across bits `[31:12]` — implemented as `{{20{instruction[31]}}, instruction[31:20]}`.
>
> ⛔ **`SRA`/`SRAI` deliberately excluded:** these share `funct3 = 101` with `SRL`/`SRLI` and are only distinguished by `funct7`, but this design's `alu_control` doesn't check `funct7` for that case — a conscious scope decision, not an oversight. See [Design Decisions](#18--key-design-decisions).

---

## 4. 🔄 How the Single-Cycle Pipeline Works

Every instruction executes **start to finish in a single clock cycle**. Only `pc_reg` and `register_file` are actual clocked registers — everything else is combinational logic that settles within that same cycle.

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│      PC      │──▶│  Instr Mem   │───▶│   Decoder    │──▶│   Reg File   │───▶│     ALU      │
└──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘
                                                                                        │ write-back
                                                                    ┐───────────────────┘
                                                                    ▼
                                                                 (write rd)
```

### Stage by stage

| Stage | What happens |
|---|---|
| **1. Address Select** | `address_sel` chooses which address feeds `instr_mem`: normally the CPU's own `pc_out`, or — only when the testbench asserts the debug `jump` signal — an externally supplied `address`, for peeking at any instruction-memory location on demand |
| **2. Fetch** | `instr_mem` combinationally returns the instruction at the selected address; on the same cycle, it also accepts a live write (`address`/`number`) from the testbench, so instructions can be injected in real time rather than only pre-loaded |
| **3. Decode** | The instruction word is bit-sliced (`opcode`, `rd`, `funct3`, `rs1`, `rs2`, `funct7`) and fed into `control_unit`, `alu_control`, and `imm_gen` |
| **4. Register Read** | `register_file` returns `read_data1`/`read_data2`; `imm_gen` produces the sign-extended immediate, in parallel |
| **5. ALU-Source Select** | `alu_src_mux` picks the ALU's second operand — `read_data2` for R-type, or the immediate for I-type — controlled by `ALUSrc` |
| **6. Execute** | `alu` computes the result, using `alu_control`'s `alu_opcode` and `flag` (for signed vs. unsigned `SLT`/`SLTU`) |
| **7. Write-Back** | The ALU's result is written into `register_file` at address `rd` — but **only if `rd != x0`** — gated by `RegWrite`. `pc_reg` advances by `4` on the same edge, unless the debug `jump` signal is holding it in place |

### ADD vs ADDI — the one real difference

| | `ADD rd, rs1, rs2` | `ADDI rd, rs1, imm` |
|---|---|---|
| ALU operand 2 source | Register file (`rs2`) | Sign-extended immediate |
| `ALUSrc` | `0` | `1` |
| Everything else | **Identical** | **Identical** |

A single control bit reroutes one wire — the rest of the datapath doesn't need to know or care which instruction is executing. Every other R-type/I-type pair in this design (`SUB`/none, `AND`/`ANDI`, `SLT`/`SLTI`, etc.) follows the same pattern.

---

## 5. 🧪 The Self-Checking Testbench Architecture

This project's verification strategy changed meaningfully during development, and it's worth explaining both the **old** approach and the **current** one, since the difference reflects a real lesson in how to design testable hardware.

### The old approach: preload-and-inspect

The earlier version of this project pre-loaded an entire program into `instr_mem` via hierarchical testbench pokes (`uut.A2.mem[0] = ...`), let the CPU run autonomously for many clock cycles, then printed final register values with `$display` for a human to read and compare against expected values written in a comment. This worked, but it had two weaknesses: it required someone to actually read and compare every line of output, and it only checked *final* state — a bug that corrupted an intermediate value but got silently overwritten later could slip through unnoticed.

### The current approach: self-checking, per-instruction regression testing

The testbench now has a live, real port-level interface into the CPU:

| Port | Direction | Purpose |
|---|---|---|
| `address` | input | Which `instr_mem` word to write to *and* — when `jump=1` — which word to fetch from |
| `number` | input | The 32-bit instruction word to write into `instr_mem[address]` |
| `jump` | input | Debug address-override: `1` = fetch from `address` this cycle and freeze the PC; `0` = normal sequential fetch from `pc_out` |
| `Reg_output` | output | Mirrors whatever the register file just wrote (or held) this cycle — the single signal every test checks |

A reusable `task load_program(rst, jump, address, number, expected)` drives one instruction in, waits one clock edge, then **automatically** compares `Reg_output` against the expected value using `!==` (a 4-state comparison that also catches unintended `X`/`Z` states, not just wrong numbers) — incrementing a pass/fail counter and printing a clear message, with no manual inspection required. The full run ends with a single summary line: `All tests passed` or `N tests failed`.

### The debug address-override mechanism, precisely

`jump` is **not** a RISC-V branch or jump instruction — there's no `BEQ`/`JAL` decoding happening anywhere in this design. It's a **testbench-only debug feature** built for verification purposes, and its actual behavior is a *freeze-and-peek*, not a *redirect*:

- **When `jump = 1`:** `instr_mem` is fetched from the testbench-supplied `address` for this one cycle, and `pc_reg` **holds its current value** (`pc_out <= pc_out`) rather than advancing — so the CPU's normal instruction stream position is completely undisturbed.
- **When `jump = 0` again on the next cycle:** the PC resumes counting up by `4` from exactly wherever it was *before* the peek, as if the peek never happened.

This lets the test suite check an arbitrary, out-of-sequence instruction-memory address (e.g. word `63`, deliberately far from the main 22-instruction program) without corrupting or skipping any part of the sequential program under test — a genuinely useful verification tool, even though it doesn't correspond to any real RISC-V instruction.

---

## 6. 🧩 How the Whole CPU Works — End-to-End Walkthrough

### 🔬 Tracing a single instruction: `add x3, x1, x2`

Assume `x1 = 5` and `x2 = 10` already sit in the register file. Here's exactly what happens, module by module, in the one clock cycle this instruction takes:

| Step | Module involved | What happens |
|---|---|---|
| ① | `address_sel` | `jump = 0`, so `fetch_address = pc_out = 8` (3rd instruction, byte address `8`) |
| ② | `instr_mem` | Returns `mem[2] = 0x002081B3` on the `instruction` wire (word index `8 >> 2 = 2`) |
| ③ | Bit-slicing (inside `riscv_core`) | `opcode = 0110011`, `rd = 00011` (x3), `funct3 = 000`, `rs1 = 00001` (x1), `rs2 = 00010` (x2), `funct7 = 0000000` |
| ④ | `control_unit` | `opcode = 0110011` → `RegWrite = 1`, `ALUSrc = 0` |
| ⑤ | `alu_control` | `funct3 = 000`, `funct7 = 0000000` → `alu_opcode = 000` (ADD) |
| ⑥ | `register_file` | `read_data1 = 5` (x1), `read_data2 = 10` (x2) |
| ⑦ | `alu_src_mux` | `ALUSrc = 0` → passes `read_data2` (10) through as `operand2` |
| ⑧ | `alu` | `5 + 10 = 15` |
| ⑨ | `register_file` (write-back) | `RegWrite = 1` and `rd = x3 ≠ x0` → `Reg[3] <= 15`, and `Reg_output <= 15` |
| ⑩ | `pc_reg` | `jump = 0` → `pc_out <= pc_out + 4 = 12` |

The testbench's `load_program` task checks exactly `Reg_output` (`15` here) against the expected value from step ⑨ — one clock edge, one instruction, one automatic pass/fail check.

### 🎬 The full 25-step verification run

| Step | `address` | `jump` | Instruction / action | Expected `Reg_output` |
|---|---|---|---|---|
| 1  | `0`  | 0 | *(reset pulse — no instruction)* | `0` |
| 2  | `0`  | 0 | `addi x1, x0, 5`   | `5` |
| 3  | `1`  | 0 | `addi x2, x0, 10`  | `10` |
| 4  | `2`  | 0 | `add x3, x1, x2`   | `15` |
| 5  | `3`  | 0 | `addi x4, x3, -3`  | `12` |
| 6  | `4`  | 0 | `add x5, x4, x4`   | `24` |
| 7  | `5`  | 0 | `addi x6, x0, -6`  | `-6` |
| 8  | `6`  | 0 | `add x7, x5, x6`   | `18` |
| 9  | `7`  | 0 | `sub x8, x7, x6`   | `24` |
| 10 | `8`  | 0 | `and x9, x7, x8`   | `16` |
| 11 | `9`  | 0 | `or x10, x7, x8`   | `26` |
| 12 | `10` | 0 | `xor x11, x7, x8`  | `10` |
| 13 | `11` | 0 | `sltu x12, x7, x8` | `1` |
| 14 | `12` | 0 | `slt x13, x7, x6`  | `0` |
| 15 | `13` | 0 | `sll x14, x12, x7` | `262144` |
| 16 | `14` | 0 | `srl x15, x14, x7` | `1` |
| 17 | `15` | 0 | `andi x16, x7, 16` | `16` |
| 18 | `16` | 0 | `ori x17, x7, 16`  | `18` |
| 19 | `17` | 0 | `xori x18, x7, 16` | `2` |
| 20 | `18` | 0 | `slli x19, x7, 2`  | `72` |
| 21 | `19` | 0 | `srli x20, x19, 2` | `18` |
| 22 | `20` | 0 | `sltiu x21, x7, 2` | `0` |
| 23 | `21` | 0 | `slti x22, x6, -2` | `1` |
| 24 | `63` | **1** | `andi x16, x7, 18` — **debug peek**, PC frozen | `18` |
| 25 | `22` | 0 | `andi x16, x7, 16` — **normal resume**, exactly where PC was left | `16` |
| 26 | `50` | **1** | `andi x16, x7, 0` — **debug peek** of a freshly-written address | `0` |
| 27 | `0`  | 0 | *(final reset pulse — clean shutdown)* | `0` |

Steps 24 and 26 are the debug address-override cases: each writes a brand-new instruction to a far-away, previously-unused word (`63`, then `50`), fetches and executes it immediately in the same cycle via the `jump` override, and confirms the result — all without disturbing the PC's position, which step 25 then confirms by resuming exactly where the main 22-instruction program left off (word `22`).

---

## 7. 📁 Project Structure (File Hierarchy)

```
riscv-single-cycle-cpu/
│
├── pc_reg.v                 # Program counter — resets to 0, holds on jump, else +4
├── tb_pc_reg.v              # Standalone testbench — pc_reg.v
│
├── address_sel.v            # Fetch-address mux — PC vs. debug-override address
├── tb_address_sel.v         # Standalone testbench — address_sel.v
│
├── instr_mem.v              # 64-word instruction memory — live write port + combinational read
├── tb_instr_mem.v           # Standalone testbench — instr_mem.v
│
├── imm_gen.v                # Sign-extends the 12-bit I-type immediate to 32 bits
├── tb_imm_gen.v             # Standalone testbench — imm_gen.v
│
├── control_unit.v           # Decodes opcode → RegWrite, ALUSrc
├── tb_control_unit.v        # Standalone testbench — control_unit.v
│
├── register_file.v          # 32×32 register file (x0 hardwired to zero, read + write)
├── tb_register_file.v       # Standalone testbench — register_file.v
│
├── alu_src_mux.v            # 2:1 mux — register value vs immediate, into the ALU
├── tb_alu_src_mux.v         # Standalone testbench — alu_src_mux.v
│
├── alu_control.v            # Decodes opcode/funct3/funct7 → alu_opcode, flag
├── tb_alu_control.v         # Standalone testbench — alu_control.v
│
├── alu.v                    # ALU_RISCV — 8-slot combinational ALU, 9 operations via flag
├── tb_alu.v                 # Standalone testbench — alu.v
│
├── riscv_core.v             # 🔝 Top-level module — wires all 9 modules above together
├── tb_riscv_core.v          # 🔝 Self-checking full-system testbench — 25-step regression suite
│
├── schematic.pdf            # Full datapath schematic / block diagram
├── io_wave.pdf               # Exported waveform view from GTKWave
├── console.pdf               # Terminal output screenshot from a full simulation run
└── dump.vcd                 # Waveform dump, generated after running any testbench
```

**Total: 24 files** — 10 core modules + 10 matching testbenches (20 files) + 4 supporting artifacts.

---

## 8. 📂 Module-by-Module Breakdown

### `pc_reg.v` — Program Counter

| Port | Direction | Width | Description |
|---|---|---|---|
| `pc_out` | output reg | 32-bit | Current program counter value |
| `jump` | input | 1-bit | When high, **holds** `pc_out` at its current value instead of advancing |
| `rst` | input | 1-bit | Synchronous reset — sets PC to 0 |
| `clk` | input | 1-bit | Clock |

Priority order: `rst` > `jump` > normal increment. When `jump = 1`, the PC does **not** load a new target — it simply pauses for one cycle, letting `address_sel` redirect the *fetch* elsewhere without moving the CPU's actual program position. Otherwise, increments by `4` every rising edge.

---

### `address_sel.v` — Fetch-Address Selector *(new module)*

| Port | Direction | Width | Description |
|---|---|---|---|
| `fetch_address` | output | 32-bit | The address actually sent to `instr_mem` for this cycle's fetch |
| `jump` | input | 1-bit | Selects between normal and debug-override fetching |
| `address` | input | 32-bit | Testbench-supplied word index (only used when `jump = 1`) |
| `pc_out` | input | 32-bit | The CPU's own program counter value |

`assign fetch_address = jump ? (address << 2) : pc_out;` — a pure combinational mux. When `jump = 0`, this is completely transparent (`fetch_address = pc_out`, identical to the CPU's original behavior). When `jump = 1`, the testbench's word-index `address` is left-shifted by 2 (converting it to a byte address) and used instead, for exactly one cycle. This module exists specifically to let the debug address-override mechanism work *without* modifying `pc_reg`'s core counting logic at all.

---

### `instr_mem.v` — Instruction Memory

| Port | Direction | Width | Description |
|---|---|---|---|
| `instruction` | output | 32-bit | Instruction word at `pc_addr` |
| `address` | input | 32-bit | Word index to write `number` into |
| `number` | input | 32-bit | Value to write into `mem[address]` |
| `pc_addr` | input | 32-bit | Byte address to fetch from (driven by `address_sel`'s `fetch_address`) |

64-word memory (`reg [31:0] mem [0:63]`). The write path is now **combinational** (`always @(*) mem[address] = number;`) rather than only pre-loaded — meaning the testbench can inject a new instruction and have it immediately readable in the very same simulation step, which is what makes the debug address-override tests (steps 24 and 26 above) work without any extra clock cycles for the write itself. `pc_addr[31:2]` converts the byte address into a word index for the read.

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

`RegWrite = 1` for both R-type (`0110011`) and I-type (`0010011`) opcodes — every instruction this core supports writes to `rd`. `ALUSrc = 1` only for I-type.

---

### `register_file.v` — 32×32 Register File

| Port | Direction | Width | Description |
|---|---|---|---|
| `Reg_output` | output reg | 32-bit | Mirrors whatever the register file just wrote (or held) this cycle — the signal the self-checking testbench actually verifies |
| `read_data1` / `read_data2` | output | 32-bit | Values read from `rs1` / `rs2` |
| `write_data` | input | 32-bit | Value to write into `rd` |
| `rd` / `rs1` / `rs2` | input | 5-bit each | Register addresses |
| `RegWrite` | input | 1-bit | Write enable |
| `rst` | input | 1-bit | Synchronous reset — clears all 32 registers and `Reg_output` |
| `clk` | input | 1-bit | Clock |

Reads are combinational, writes are clocked. `x0` is now protected on **both** sides: reads force `0` regardless of stored content (`(rs1 == 0) ? 0 : Reg[rs1]`), and the write itself is guarded (`if (RegWrite && rd != 5'b0)`), so `x0` can never actually be overwritten in the first place — a stricter, double-layer enforcement of the RISC-V spec's zero-register requirement compared to the read-only guard used earlier in development.

---

### `alu_src_mux.v` — ALU Operand-2 Selector

| Port | Direction | Width | Description |
|---|---|---|---|
| `operand2` | output | 32-bit | Selected ALU second operand |
| `read_data2` | input | 32-bit | Value from register file (`rs2`) |
| `imm_out` | input | 32-bit | Sign-extended immediate |
| `ALUsrc` | input | 1-bit | Select line from `control_unit` |

The 2:1 mux that implements the entire R-type/I-type operand-source distinction.

---

### `alu_control.v` — ALU Control

| Port | Direction | Width | Description |
|---|---|---|---|
| `alu_opcode` | output reg | 3-bit | Operation code fed to `alu` |
| `flag` | output | 1-bit | `1` for signed `SLT`/`SLTI`, `0` for unsigned `SLTU`/`SLTIU` |
| `opcode` | input | 7-bit | Instruction opcode |
| `funct3` | input | 3-bit | Instruction funct3 field |
| `funct7` | input | 7-bit | Instruction funct7 field |

Maps every supported `funct3` (both R-type and I-type) to the matching `alu_opcode`. Disambiguates `ADD` vs `SUB` using `funct7`. `flag = (funct3 == 3'b010)` — true only for `SLT`/`SLTI`, false for `SLTU`/`SLTIU`, letting the ALU choose signed vs. unsigned comparison for the shared `alu_opcode = 101` slot. `SRA`/`SRAI` are not distinguished from `SRL`/`SRLI` — see [Section 3](#3--instruction-encoding--r-type--i-type).

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
| `101` | SLT (signed, `flag=1`) / SLTU (unsigned, `flag=0`) |
| `110` | SLL |
| `111` | SRL |

All 8 opcode slots are used — `SLT` and `SLTU` share slot `101`, distinguished at compute-time by `flag` using Verilog's `$signed()` cast for the signed comparison.

---

### `riscv_core.v` — Top-Level Core 🔝

| Port | Direction | Width | Description |
|---|---|---|---|
| `Reg_output` | output | 32-bit | The value the register file just wrote/held this cycle |
| `address` | input | 32-bit | `instr_mem` write target; also the debug-override fetch address when `jump=1` |
| `number` | input | 32-bit | Instruction word to write into `instr_mem[address]` |
| `jump` | input | 1-bit | Debug address-override / PC-freeze control |
| `rst` | input | 1-bit | Global reset |
| `clk` | input | 1-bit | Global clock |

**Internal instance names** (used for hierarchical inspection):

| Module | Instance name |
|---|---|
| `pc_reg` | `A1` |
| `address_sel` | `A2` |
| `instr_mem` | `A3` |
| `imm_gen` | `A4` |
| `control_unit` | `A5` |
| `register_file` | `A6` |
| `alu_src_mux` | `A7` |
| `alu_control` | `A8` |
| `alu` (`ALU_RISCV`) | `A9` |

Contains no logic of its own beyond instruction-field bit-slicing — purely instantiation and wiring.

---

## 9. 🧪 Testbenches — Self-Checking Suite & Standalone Unit Tests

This project has **10 testbenches** — one per hardware module — but they fall into two clearly different tiers, and it's worth keeping them conceptually separate rather than treating them as a uniform pile of "test files."

### Tier 1 — `tb_riscv_core.v`: the self-checking, full-system testbench 🔝

This is the **only** testbench that exercises the fully assembled `riscv_core` top module, and the only one that's genuinely self-checking rather than a manually-inspected waveform dump.

| Aspect | Detail |
|---|---|
| Instantiates | `riscv_core` with all 6 ports connected (`Reg_output, address, number, jump, rst, clk`) |
| Mechanism | A reusable `task load_program(rst, jump, address, number, expected)` — drives one instruction/action in, advances one clock edge, and automatically checks `Reg_output` |
| Comparison | `!==` — a 4-state comparison that catches `X`/`Z` (unintended unknown states), not just wrong numeric values |
| Reporting | Increments a running pass/fail counter per step, prints a per-step message, and ends with a single automatic summary line (`All tests passed` or `N tests failed`) |
| Coverage | The full 25-step regression suite — all 9 ALU operations (R-type and I-type), chained data dependencies, negative numbers, signed vs. unsigned comparison, and the debug address-override mechanism |

Full details on *why* it's built this way — including the live instruction-memory write port and the freeze-and-peek debug mechanism — are in [Section 5](#5--the-self-checking-testbench-architecture). The complete step-by-step program with every expected value is in [Section 6](#6--how-the-whole-cpu-works--end-to-end-walkthrough) and [Section 10](#10--verification-program--all-25-test-steps).

### Tier 2 — Standalone module testbenches: one module tested in isolation at a time

Each of the other 9 modules has its own dedicated testbench that drives that module's ports directly — no `riscv_core`, no clock-driven program, just the module's own inputs and outputs checked against known-correct behavior. These are the ones you'd reach for first when tracking down a bug in one specific piece of logic, without needing to run the whole CPU to see it.

| Testbench | Module tested | What it's built to verify |
|---|---|---|
| `tb_pc_reg.v` | `pc_reg.v` | Reset-to-zero behavior, normal `+4` increment every cycle, and the hold behavior when `jump=1` |
| `tb_address_sel.v` | `address_sel.v` | Correct pass-through of `pc_out` when `jump=0`, and correct `(address << 2)` substitution when `jump=1` |
| `tb_instr_mem.v` | `instr_mem.v` | The live combinational write path (`mem[address] = number` visible immediately) and correct word-index read via `pc_addr[31:2]` |
| `tb_imm_gen.v` | `imm_gen.v` | Correct sign-extension for both positive and negative 12-bit immediates |
| `tb_control_unit.v` | `control_unit.v` | `RegWrite`/`ALUSrc` correctness across the R-type opcode, the I-type opcode, and an unrecognized opcode |
| `tb_register_file.v` | `register_file.v` | `x0` always reads as `0` regardless of what's written; correct write-then-read behavior for `rd != 0`; reset clears all 32 registers |
| `tb_alu_src_mux.v` | `alu_src_mux.v` | Correct 2:1 selection between `read_data2` and `imm_out` based on `ALUsrc` |
| `tb_alu_control.v` | `alu_control.v` | Sweeps `funct3` through all 8 values (`000`–`111`) for both the R-type and I-type opcodes, including both `funct7` values on the `000` case to confirm `ADD`/`SUB` disambiguation, plus an unrecognized-opcode case to confirm the `default` fallback |
| `tb_alu.v` | `alu.v` (`ALU_RISCV`) | A fixed operand pair driven through all 8 `alu_opcode` values with `flag=0`, plus a final case with `flag=1` and two *negative* operands through the `SLT` path — a genuinely negative-vs-negative signed comparison, not just negative-vs-positive |

> 📝 **A note on confidence level:** the `tb_alu_control.v` and `tb_alu.v` rows above are described from directly-reviewed source code. The other seven standalone testbenches follow the identical isolated-single-module testing pattern established by those two — driving the module's exact port list with a sequence of input combinations and inspecting the output — but are documented here at the level of "what this testbench is built to verify" based on the module's own contract, since covering *every* module the same rigorous way was the design intent for this tier.

### Why two tiers, not one flat pile of tests

Standalone tests are fast to write, fast to run, and pinpoint exactly which module misbehaves — but they can't catch integration bugs (wrong port order at instantiation, a signal wired to the wrong wire in `riscv_core`, timing assumptions that only break when modules are actually chained together). The self-checking full-system test exists specifically to catch *that* category of bug — several of the entries in [Section 15's Debugging Journey](#15--debugging-journey--bugs-found--fixed) (like Bug 7's reset-ordering issue, and Bug 11's same-cycle jump timing problem) were integration-level bugs that no single-module testbench could have caught on its own, since each individual module was behaving exactly as designed in isolation.

---

## 10. 🧾 Verification Program — All 25 Test Steps

See the full step-by-step table with expected values in [Section 6](#6--how-the-whole-cpu-works--end-to-end-walkthrough) above. In short, the program:

1. Establishes two constants via `ADDI x0`-seeding (`x1=5`, `x2=10`)
2. Chains a data dependency through `ADD`/`ADDI` (`x3` → `x4` → `x5`)
3. Introduces a negative immediate (`x6 = -6`) and combines it with earlier values
4. Exercises all 9 R-type ALU operations, using the running values as real operands rather than fixed constants
5. Exercises all 8 I-type immediate operations against the same operand for easy cross-checking against their R-type counterparts
6. Specifically tests **signed vs. unsigned comparison** (`SLTU` at step 13, `SLT` at step 14 — same operand, opposite-sign comparison logic) and a **negative-vs-negative signed comparison** (step 23, `x6=-6` vs. `-2`)
7. Exercises the **debug address-override mechanism** twice (steps 24 and 26) — writing and immediately executing instructions at far-away, previously-unused memory addresses (`63` and `50`) without disturbing the main program's sequential position, confirmed by step 25 resuming exactly where it left off

Every one of these 27 total task calls (25 numbered steps plus the opening and closing reset pulses) is checked automatically — the testbench prints `All tests passed` only if every single one matches exactly.

---

## 11. 📥 How to Download This Project

1. Go to the repository's GitHub page.
2. Click the green **`<> Code`** button near the top right.
3. Click **Download ZIP**.
4. Once downloaded, right-click the `.zip` file → **Extract All...** → choose a folder (e.g. `C:\Projects\riscv-single-cycle-cpu`).

Alternatively, if you have Git installed on Windows (via [Git for Windows](https://git-scm.com/download/win)):

```bash
git clone https://github.com/tirth24102006/RV32I-Single-Cycle-RISC-V-CPU.git
cd RV32I-Single-Cycle-RISC-V-CPU
```

---

## 12. 🪟 How to Run on Windows

### Step 1 — Install VS Code

1. Download from [code.visualstudio.com](https://code.visualstudio.com/) and run the installer.
2. During install, check **"Add to PATH"** if prompted.
3. *(Optional but recommended)* Install the **Verilog-HDL/SystemVerilog** extension from the Extensions marketplace (`Ctrl+Shift+X` → search "Verilog") for syntax highlighting.

### Step 2 — Install Icarus Verilog

1. Go to [bleyer.org/icarus](http://bleyer.org/icarus/) and download the latest Windows installer (`iverilog-vX.X-X-setup.exe`).
2. Run the installer.
3. ⚠️ **Important:** make sure **"Add Icarus Verilog to PATH"** (or similar wording) is checked during install — this lets you run `iverilog` and `vvp` from any terminal.
4. GTKWave is bundled with this same installer — no separate download needed.
5. Verify the install: open **Command Prompt** or **PowerShell** and run `iverilog -v` — you should see version information, not a "command not found" error.

### Step 3 — Open the project folder in VS Code

1. **File → Open Folder...** → select the extracted/cloned project folder.
2. Open a terminal inside VS Code: **Terminal → New Terminal** (or `` Ctrl+` ``).

### Step 4 — Compile the full-system testbench

```bash
iverilog -o tb_riscv_core.out tb_riscv_core.v riscv_core.v pc_reg.v address_sel.v instr_mem.v register_file.v imm_gen.v control_unit.v alu_control.v alu_src_mux.v alu.v
```

### Step 5 — Run the simulation

```bash
vvp tb_riscv_core.out
```

This prints each test's pass/fail line plus the final summary to your terminal, and generates `dump.vcd`.

### Step 6 — View the waveform in GTKWave

```bash
gtkwave dump.vcd
```

In the **SST** panel on the left, click `tb_riscv_core`, then double-click signals (`clk`, `rst`, `jump`, `address`, `number`, `Reg_output`) to add them to the waveform viewer.

> 💡 **To test one module in isolation** (e.g. just the new `address_sel`), compile its matching testbench instead:
> ```bash
> iverilog -o tb_address_sel.out tb_address_sel.v address_sel.v
> vvp tb_address_sel.out
> ```

### Step 7 (Optional) — Using Xilinx Vivado on Windows

1. Download and install **Vivado** (Windows native installer) — the free **WebPACK** edition is enough.
2. **Create Project** → **RTL Project**.
3. **Add Sources** → add all 10 `.v` module files as **Design Sources**.
4. Add `tb_riscv_core.v` separately as a **Simulation Source**.
5. Right-click `tb_riscv_core` under Simulation Sources → **Set as Top**.
6. **Flow Navigator → Simulation → Run Behavioral Simulation.**
7. Add `clk`, `rst`, `jump`, `address`, `number`, `Reg_output` to the waveform viewer.
8. *(Optional, for synthesis)* Set `riscv_core` (not the testbench) as **Top**, then run **Synthesis → Implementation**.

---

## 13. 🐧🍎 How to Run on macOS / Linux

**Install (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install iverilog gtkwave
```

**Install (macOS, Homebrew):**
```bash
brew install icarus-verilog gtkwave
```

**Compile, run, and view:**
```bash
iverilog -o tb_riscv_core.out tb_riscv_core.v riscv_core.v pc_reg.v address_sel.v instr_mem.v register_file.v imm_gen.v control_unit.v alu_control.v alu_src_mux.v alu.v
vvp tb_riscv_core.out
gtkwave dump.vcd
```

---

## 14. 🖥️ Sample Simulation Output

```
----------------------------------------------------------------------------------------
--------- start tasting ---------
----------------------------------------------------------------------------------------
Test 1 passed: Reg_output =           0
Test 2 passed: Reg_output =           5
Test 3 passed: Reg_output =          10
Test 4 passed: Reg_output =          15
Test 5 passed: Reg_output =          12
Test 6 passed: Reg_output =          24
Test 7 passed: Reg_output =          -6
Test 8 passed: Reg_output =          18
Test 9 passed: Reg_output =          24
Test 10 passed: Reg_output =          16
Test 11 passed: Reg_output =          26
Test 12 passed: Reg_output =          10
Test 13 passed: Reg_output =           1
Test 14 passed: Reg_output =           0
Test 15 passed: Reg_output =      262144
Test 16 passed: Reg_output =           1
Test 17 passed: Reg_output =          16
Test 18 passed: Reg_output =          18
Test 19 passed: Reg_output =           2
Test 20 passed: Reg_output =          72
Test 21 passed: Reg_output =          18
Test 22 passed: Reg_output =           0
Test 23 passed: Reg_output =           1
Test 24 passed: Reg_output =          18
Test 25 passed: Reg_output =          16
Test 26 passed: Reg_output =           0
Test 27 passed: Reg_output =           0
----------------------------------------------------------------------------------------
--------- All tests passed ---------
----------------------------------------------------------------------------------------
```

📸 See `console.pdf` for the terminal output shown above as an actual screenshot/export, `io_wave.pdf` for the corresponding GTKWave waveform, and `schematic.pdf` for the full block-level datapath diagram.

---

## 15. 🐞 Debugging Journey — Bugs Found & Fixed

This project wasn't written correctly on the first attempt — nothing hand-built ever is. Every module went through a write → review → fix → re-verify cycle. Documenting the real bugs is deliberate: these are exactly the mistakes anyone hand-writing Verilog is likely to make, and recognizing the *pattern* is more useful than just seeing correct code.

### 🔴 Bug 1 — `output reg` vs. `assign` mismatch
**Symptom:** Compile error. **Cause:** A port declared `output reg` was then driven with a continuous `assign` — `assign` can only drive a `wire`. **Fix:** Match declaration to assignment style, every time.

### 🔴 Bug 2 — Case-sensitive typos creating phantom signals
**Symptom:** Compile error, or a silently disconnected signal. **Cause:** Verilog is case-sensitive; a typo like `Write_data` instead of `write_data` can silently create a brand-new, unrelated wire instead of throwing an obvious error. **Fix:** Careful line-by-line comparison between the port list and every usage inside the module body.

### 🔴 Bug 3 — Malformed replication operator
**Symptom:** Compile error. **Cause:** `{20{1'b1}, ...}` is missing the inner replication operator's own closing brace. **Fix:** `{{20{1'b1}}, ...}` — doubled `{{` is required syntax.

### 🔴 Bug 4 — `x0` not actually hardwired to zero
**Symptom:** No compile error — silently wrong results whenever `x0` is read. **Cause:** Nothing in a naive register file enforces the RISC-V spec's "`x0` always reads as `0`" rule. **Fix (evolved over two rounds):** first, force the *read* path (`(rs1==0) ? 0 : Reg[rs1]`); later, in the final version, *also* guard the *write* path (`if (RegWrite && rd != 5'b0)`) so `x0` can never be written in the first place — a stricter, belt-and-suspenders enforcement.

### 🔴 Bug 5 — Blocking (`=`) vs. non-blocking (`<=`) assignment, used backwards
**Symptom:** No compile error — simulator-dependent correctness bug. **Cause:** `<=` belongs in clocked `always @(posedge clk)` blocks; `=` belongs in combinational `always @(*)` blocks — mixed up in early drafts of `pc_reg` and `alu_control`. **Fix:** Match the operator to the block type with no exceptions.

### 🔴 Bug 6 — Testbench race condition between two `initial` blocks
**Symptom:** Simulator-dependent, unpredictable initial values. **Cause:** Two separate `initial` blocks both touching `clk`/`rst` at simulation time `0`, with no guaranteed order *between* blocks. **Fix:** Kept as two blocks only because they don't actually contend over the same signal at the same instant in the final design.

### 🔴 Bug 7 — Loading instructions after releasing reset
**Symptom:** First instruction(s) execute using garbage (`X`) data. **Cause:** `rst` was released before `instr_mem` had valid data. **Fix:** Ensure memory is populated while `rst` is still asserted — later made moot entirely by switching to a live per-cycle write port (see Bug 9 below).

### 🔴 Bug 8 — `%0d` printing negative registers as huge unsigned numbers
**Symptom:** `-6` printed as `4294967290`. **Cause:** `%d` only prints signed if the variable is `$signed()`-cast or declared `signed` — plain `reg` is unsigned by default. **Fix:** Wrap the read in `$signed(...)` at display time, exactly as the current testbench does for `exp_Reg_output` and `Reg_output` in every failure/pass message.

### 🔴 Bug 9 — `SLT` computing an unsigned comparison despite its name
**Symptom:** Silently wrong `SLT` result whenever a sign bit was set. **Cause:** `operand1 < operand2` on unsigned wires always compares unsigned, regardless of intent. **Fix:** A dedicated `flag` signal (from `alu_control`, based on `funct3`) selects between `$signed()` comparison and plain comparison inside the ALU — and since this meant `SLT`/`SLTU` had to share a single 3-bit opcode slot, `flag` also became the secondary selector distinguishing them.

### 🔴 Bug 10 — Vivado `place_design` error: "The design is empty"
**Symptom:** Simulation works perfectly; Synthesis/Implementation fails immediately. **Cause:** An earlier version of `riscv_core` had only `rst`/`clk` as ports — no outputs — so `opt_design` correctly concluded none of the internal logic could ever affect anything observable and optimized the entire design away. **Fix:** Add a real, internally-driven output port. The final architecture goes further than the minimal fix — `Reg_output` is now a genuinely meaningful, always-live output, not just a synthesis workaround.

### 🔴 Bug 11 — Debug jump executed one cycle "early" relative to the PC
**Symptom:** A test asserting the debug `jump` override and checking the result in the same call initially returned garbage instead of the intended instruction. **Cause:** An early design of the jump mechanism tried to have `pc_reg` load a *target* address on the same edge the fetch needed to already reflect it — but a register's new value isn't visible until *after* the clock edge, so the fetch that cycle still used the *old* PC value, reading from unwritten memory. **Fix:** Redesigned the mechanism entirely — rather than making the PC jump to a target, `address_sel` now intercepts the *fetch address* combinationally (bypassing `pc_out` entirely for that one cycle) while `pc_reg` simply *holds* rather than moves. This makes the override take effect immediately, in the same cycle it's asserted, with no extra latency — and as a side effect, it no longer disturbs the PC's sequential position at all, which turned out to be a more useful property than the original "jump to a target" design would have had.

---

## 16. 📘 Verilog Concepts Reference

### Combinational vs. sequential logic

| | Combinational | Sequential (clocked) |
|---|---|---|
| Trigger | `always @(*)` | `always @(posedge clk)` |
| Assignment operator | `=` (blocking) | `<=` (non-blocking) |
| Represents | Logic gates — output recomputed instantly from current inputs | A register — holds a value until explicitly told to update |
| Used in this project for | `alu`, `alu_control`, `control_unit`, `imm_gen`, `alu_src_mux`, `address_sel`, `instr_mem`'s write & read paths | `pc_reg`, `register_file`'s write port |

### `output` vs. `output reg`

If a port is driven with a continuous `assign` statement → declare it plain `output` (`wire`). If it's driven inside an `always` block (either kind) → declare it `output reg`. `reg` does **not** inherently mean "flip-flop" — a `reg` driven only inside a combinational `always @(*)` block still synthesizes to plain logic gates.

### Sign-extension with the replication operator

```verilog
{{20{instruction[31]}}, instruction[31:20]}
```

Take `instruction[31]` (the sign bit), repeat it `20` times, then concatenate the original 12-bit field after it. The doubled `{{` is required syntax: the inner `{N{value}}` replication operator must sit inside the outer `{...}` concatenation.

### `$signed()` — interpreting bits as signed without changing them

`$signed(value)` doesn't modify any bits — it's a cast telling the surrounding expression (a comparison, arithmetic, or a `$display` format specifier) to interpret the bit pattern as two's-complement signed. Used both *inside* the ALU's `SLT` computation and at `$display` time for negative test values.

### Hierarchical references — simulation-only visibility

```verilog
$display("%0d", uut.A6.Reg[1]);   // reach into register_file's internal array
```

Works regardless of whether a signal is a top-level port — but this is a **simulation-only** convenience. Real synthesized hardware can only be probed at actual physical pins, which is why `riscv_core` needed a genuine output port (`Reg_output`) for synthesis to succeed, even though hierarchical references made that technically unnecessary just for simulation.

### `!==` vs. `!=` — 4-state vs. 2-state comparison

| Operator | Behavior with `X`/`Z` |
|---|---|
| `!=` | Ambiguous/undefined result if either operand contains `X` or `Z` |
| `!==` | Exact 4-state comparison — `X !== 5` is unambiguously `true` (they're not equal) |

This project's self-checking testbench deliberately uses `!==`, so an unintended `X` propagating through the design (e.g. from an unwritten memory address) is correctly flagged as a test failure rather than silently ignored.

### `%d` vs `%h` vs `%b` in `$display`/`$monitor`

| Specifier | Prints | Signed-aware? |
|---|---|---|
| `%b` | Raw binary | No — always literal bits |
| `%h` | Raw hexadecimal | No — always literal bits |
| `%d` | Decimal | Only if wrapped in `$signed(...)` or the variable is declared `signed` |

---

## 17. 🚧 Current Limitations & Roadmap

This project is **feature-complete for its intended scope**. Documented here for anyone who wants to fork and extend it:

- ⛔ `SRA`/`SRAI` — **intentionally excluded**, not a missing feature (see [Design Decisions](#18--key-design-decisions))
- ⛔ Real RISC-V branch/jump instructions (`BEQ`, `JAL`, etc.) — the `jump` signal in this design is a **testbench-only debug feature**, not ISA-level branch support; see [Section 5](#5--the-self-checking-testbench-architecture)
- 🔭 `LOAD`/`STORE` support — would require a separate data memory module and `MemRead`/`MemWrite`/`MemtoReg` control signals
- 🔭 Actual branch instructions — would require a branch comparator, PC-relative addressing, and real opcode/funct3 decoding for `BEQ`/`BNE`/etc.
- 🔭 `LUI`/`AUIPC`/`JAL`/`JALR` — would require U-type/J-type immediate decoding and real PC write-back paths
- 🔭 Pipelining and hazard handling — would only become relevant if this evolved beyond a single-cycle design

The 🔭 items are **not planned** — left here only as a reference for what further extension would involve.

---

## 18. 🔑 Key Design Decisions

**Single-cycle instead of a shared-bus multi-cycle design.** Matches how RV32I's fixed-length, cleanly-fielded format is meant to be used — every instruction fully executes in one clock edge, with no bus arbitration needed.

**Separate `control_unit` and `alu_control`.** Mirrors real CPU design practice — datapath-wide signals versus ALU-specific operation selection — keeping each module focused and easy to extend independently.

**`x0` guarded on both the read *and* write path.** The read guard alone (`(rs1==0)?0:Reg[rs1]`) is sufficient for correctness, but adding a write guard (`rd != 5'b0`) as well means `x0`'s storage location can never even *become* nonzero — a defense-in-depth choice, not a strictly required one.

**`SLT`/`SLTU` sharing one ALU opcode slot via `flag`, rather than widening `alu_opcode`.** With all 8 values of a 3-bit `alu_opcode` already assigned to the original 8 operations, adding a 9th operation could have meant widening to 4 bits. Instead, since `SLT` and `SLTU` are the *same* operation with only their sign-interpretation differing, a single extra 1-bit `flag` signal was enough — a smaller, more surgical change than a global opcode-width increase.

**`address_sel` as its own module rather than inline logic.** The fetch-address mux is one line of logic, but separating it lets it be tested in complete isolation (`tb_address_sel.v`) and makes the debug address-override mechanism's exact behavior explicit and easy to point to, rather than buried as an anonymous `assign` inside `riscv_core`.

**The debug `jump` mechanism freezes the PC rather than redirecting it.** An earlier design attempted to make `jump` load a real target address into `pc_reg` — but that runs into the fundamental one-cycle latency of sequential logic (Bug 11 above): a register's new value isn't visible until the cycle *after* it's set, so a same-cycle "jump and immediately fetch from there" isn't achievable by updating the PC alone. Freezing the PC and combinationally overriding the *fetch address* instead sidesteps that latency entirely, at the cost of this not being a real jump/branch — a deliberate trade, since the goal was verification tooling, not ISA completeness.

**`SRA`/`SRAI` excluded rather than half-implemented.** Since only `SRL`/`SRLI` are in scope, `funct7` doesn't need to be checked for `funct3 = 101` at all — checking it would add complexity in service of a case that's explicitly not supported, so the simpler code was chosen deliberately.

**Self-checking over "load a program and eyeball the output."** Manually comparing a wall of `$display` lines against comments doesn't scale and is error-prone for a human reviewer. A `task`-based, `!==`-checked, pass/fail-counted testbench catches regressions automatically and scales cleanly as more test cases are added.

---

## 19. 📖 Glossary of Terms

| Term | Meaning |
|---|---|
| **RISC** | Reduced Instruction Set Computer — small set of simple, fixed-length instructions |
| **CISC** | Complex Instruction Set Computer — larger set of variable-length, more capable instructions |
| **ISA** | Instruction Set Architecture — the contract between hardware and software |
| **RV32I** | The 32-bit base integer instruction set of RISC-V |
| **Opcode** | The lowest 7 bits of an instruction — identifies its broad format |
| **funct3** | A 3-bit field narrowing down the specific operation within an opcode's category |
| **funct7** | A 7-bit field (R-type only) disambiguating operations sharing the same opcode/funct3 |
| **Immediate (`imm`)** | A constant encoded directly into the instruction word |
| **Sign extension** | Extending a signed value to a wider bit-width by replicating its sign bit |
| **Two's complement** | The standard binary representation for signed integers |
| **Register file** | The bank of general-purpose registers (`x0`–`x31` in RV32I) a CPU operates on |
| **`x0` / zero register** | A register hardwired to always read (and, in this design, write) as `0` |
| **Datapath** | The hardware data actually flows through during execution |
| **Control logic** | Hardware that decodes instructions and generates the signals steering the datapath |
| **Single-cycle CPU** | A CPU where every instruction completes in one clock cycle |
| **Combinational logic** | Logic whose output depends only on current inputs, no memory |
| **Sequential logic** | Logic with memory — updates only on clock edges |
| **Write-back** | The stage where a computed result is stored into the register file |
| **Self-checking testbench** | A testbench that automatically compares actual vs. expected results and reports pass/fail, with no manual inspection required |
| **4-state comparison (`!==`)** | A comparison that treats `X`/`Z` as real, distinct values rather than ambiguous |
| **Hierarchical reference** | A dotted simulation-only path (`top.instance.signal`) reaching into nested module instances |
| **Testbench** | A non-synthesizable simulation-only module that drives and checks a design |
| **Synthesis** | Translating Verilog RTL into an actual gate-level or FPGA-primitive implementation |
| **`opt_design` / `place_design`** | Vivado's optimization and physical-placement stages during Implementation |

---

## 20. 👤 Author

Built module-by-module, bug-by-bug, from a blank file to a working, self-checking RISC-V core — every line reviewed, debugged, and understood along the way rather than copy-pasted. 🛠️

Feel free to fork, ⭐ star, and extend this with more of the RV32I instruction set. Pull requests and issues welcome!

---

## 21. 📄 License

MIT License — free to use, modify, and distribute with attribution.
