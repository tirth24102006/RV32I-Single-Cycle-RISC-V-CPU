# RV32I-Single-Cycle-RISC-V-CPU
A minimal single-cycle 32-bit RISC-V (RV32I) CPU built from scratch in Verilog HDL, executing ADD and ADDI. Fully modular datapath — PC, instruction memory, register file, ALU, control unit, ALU control, immediate generator, and ALU-source mux — each with its own testbench, simulated in Icarus Verilog and visualized in GTKWave &amp; Vivado. 🚀

# 🧠 RV32I Single-Cycle RISC-V CPU (ADD / ADDI Subset) — Built From Scratch in Verilog

> ⚙️ A fully modular, single-cycle 32-bit RISC-V processor, hand-built in Verilog HDL from the ground up — implementing the `ADD` and `ADDI` instructions from the RV32I base integer instruction set. Every stage of the classic **Fetch → Decode → Execute → Write-Back** pipeline is broken into its own clean, independently testable module — Program Counter, Instruction Memory, Register File, Immediate Generator, Control Unit, ALU Control, ALU-Source Mux, and the ALU itself — all wired together in a single top-level core and verified with both per-module and full-system testbenches. Simulated with Icarus Verilog, inspected in GTKWave, and synthesizable in Xilinx Vivado. 🚀

---

## 📑 Table of Contents

- [1. 📌 Project Highlights](#1--project-highlights)
- [2. 🧠 What is RISC-V, RISC vs CISC, and RV32I?](#2--what-is-risc-v-risc-vs-cisc-and-rv32i)
- [3. 🔍 Instruction Encoding — R-type & I-type](#3--instruction-encoding--r-type--i-type)
- [4. 🔄 How the Single-Cycle Pipeline Works](#4--how-the-single-cycle-pipeline-works)
- [5. 📁 Project Structure (File Hierarchy)](#5--project-structure-file-hierarchy)
- [6. 📂 Module-by-Module Breakdown](#6--module-by-module-breakdown)
- [7. 🧪 Test Program Used for Verification](#7--test-program-used-for-verification)
- [8. ⚙️ How to Run This Project](#8-️-how-to-run-this-project)
  - [8.1 🧩 Using VS Code + Icarus Verilog + GTKWave](#81--using-vs-code--icarus-verilog--gtkwave)
  - [8.2 🏗️ Using Xilinx Vivado](#82-️-using-xilinx-vivado)
- [9. 🖥️ Sample Simulation Output](#9-️-sample-simulation-output)
- [10. 🔑 Key Design Decisions](#10--key-design-decisions)
- [11. 🚧 Current Limitations & Future Roadmap](#11--current-limitations--future-roadmap)
- [12. 👤 Author](#12--author)
- [13. 📄 License](#13--license)

---

## 1. 📌 Project Highlights

- ✅ Fully working **single-cycle 32-bit RISC-V datapath**, built entirely from first principles
- ✅ Implements real **RV32I** encoding — `ADD` (R-type) and `ADDI` (I-type), matching the official RISC-V ISA spec bit-for-bit
- ✅ **9 independent hardware modules**, each with its own dedicated testbench (18 files total)
- ✅ Fully working **32×32 register file** with `x0` hardwired to zero, exactly as the RISC-V spec requires
- ✅ Combinational **instruction memory** with correct byte-to-word address translation (`pc_addr[31:2]`)
- ✅ Extensible **ALU** (8 opcodes wired in, though only `ADD`/`SUB` are exercised by this instruction subset)
- ✅ Proper **sign-extended immediate generation** for I-type instructions, tested against negative immediates
- ✅ Clean separation of **control logic** (`control_unit`, `alu_control`) from the **datapath** (`alu`, `register_file`, `pc_reg`, etc.) — the same architectural principle real CPUs use
- ✅ Full-system testbench (`tb_riscv_core`) that hand-loads a 5-instruction program and verifies every register's final value
- ✅ Verified with **Icarus Verilog + GTKWave**, and structured to be synthesizable in **Xilinx Vivado**
- ✅ Every module was built and debugged iteratively — line-by-line review, bug fixes, and re-verification — a genuinely hand-crafted CPU, not copy-pasted

---

## 2. 🧠 What is RISC-V, RISC vs CISC, and RV32I?

### RISC vs CISC

| | CISC (e.g. x86) | RISC (e.g. RISC-V, ARM, MIPS) |
|---|---|---|
| Instructions | Complex, can do multiple operations per instruction | Simple, one operation per instruction |
| Length | Variable (1–15 bytes) | Fixed (32 bits in RV32I) |
| Memory access | Any instruction can touch memory | Only `LOAD`/`STORE` touch memory |
| Philosophy | Smart hardware, simple compiler | Simple hardware, smart compiler |
| Pipelining | Harder (variable-length decode) | Easy (fixed-length, uniform fields) |

RISC-V's simplicity — fixed 32-bit instructions with clean, uniform bit-fields — is exactly what makes a **single-cycle CPU** like this one feasible to hand-build; a CISC ISA like x86 would be far too complex to decode and execute in one clock cycle.

### Why "RISC-V"? 🔢

The "V" is the **Roman numeral 5** — this is the **fifth** RISC architecture from UC Berkeley's research lineage (RISC-I → RISC-II → RISC-III/SOAR → RISC-IV/SPUR → **RISC-V**). It isn't a software-style "version 5" — it's literally the fifth chip design in that academic lineage, which then became a free, open, royalty-free ISA standard — unlike proprietary ISAs like x86 (Intel/AMD) or ARM (licensed).

### What is RV32I?

| Part | Meaning |
|---|---|
| **RV** | RISC-V |
| **32** | 32-bit registers & address space |
| **I** | Base **Integer** instruction set — the mandatory minimum every RISC-V CPU must support |

RV32I contains **~47 base instructions** (arithmetic, logic, loads, stores, branches, jumps). This project implements a deliberate minimal subset — just **`ADD`** and **`ADDI`** — to prove out the entire datapath end-to-end before scaling up to the full instruction set.

---

## 3. 🔍 Instruction Encoding — R-type & I-type

Every RISC-V instruction is a fixed **32 bits**. Our two instructions use these two formats:

### R-type (`ADD`)
```
 31        25 24     20 19     15 14    12 11      7 6        0
┌────────────┬─────────┬─────────┬────────┬──────────┬─────────┐
│  funct7    │   rs2   │   rs1   │ funct3 │    rd    │  opcode │
└────────────┴─────────┴─────────┴────────┴──────────┴─────────┘
```

### I-type (`ADDI`)
```
 31                  20 19     15 14    12 11      7 6        0
┌──────────────────────┬─────────┬────────┬──────────┬─────────┐
│    imm[11:0]         │   rs1   │ funct3 │    rd    │  opcode │
└──────────────────────┴─────────┴────────┴──────────┴─────────┘
```

### Encoding table for the instructions used in this project

| Instruction | opcode | funct3 | funct7 | Notes |
|---|---|---|---|---|
| `ADD`  | `0110011` | `000` | `0000000` | R-type — reads `rs1` & `rs2` |
| `SUB`  | `0110011` | `000` | `0100000` | R-type — wired in `alu_control` for extensibility, not used by the test program |
| `ADDI` | `0010011` | `000` | — | I-type — reads `rs1` + 12-bit sign-extended immediate |

> 🧾 **Immediates are sign-extended**: the 12-bit `imm[11:0]` field is extended to 32 bits by replicating bit `[31]` of the instruction (the immediate's sign bit) across bits `[31:12]` — implemented as `{{20{instruction[31]}}, instruction[31:20]}`.

---

## 4. 🔄 How the Single-Cycle Pipeline Works

Unlike a multi-cycle, bus-based design (SAP-1 style), this CPU executes **one full instruction, start to finish, in a single clock cycle** — everything below happens combinationally within one cycle, with only the Program Counter and Register File actually being clocked registers.

```
   ┌────────┐     ┌───────────┐     ┌─────────┐     ┌──────────────┐     ┌────────┐
   │  PC    │────▶│ Instr Mem │────▶│ Decoder │────▶│  Reg File    │────▶│  ALU   │
   │(pc_reg)│     │(instr_mem)│     │(bitslice)│    │(register_file)│    │(alu)  │
   └────────┘     └───────────┘     └─────────┘     └──────────────┘     └───┬────┘
                                                                              │
                                                                        write-back
                                                                              │
                                                                              ▼
                                                                    Reg File (write port)
```

### Stage-by-stage

1. **Fetch** — `pc_reg` holds the current address; `instr_mem` combinationally returns the 32-bit instruction at that address (using `pc_addr[31:2]` to convert the byte address into a word index).
2. **Decode** — the instruction word is bit-sliced directly (`opcode`, `rd`, `funct3`, `rs1`, `rs2`, `funct7`) and fed into `control_unit`, `alu_control`, and `imm_gen`.
3. **Register Read** — `register_file` combinationally returns `read_data1` (rs1) and `read_data2` (rs2); `imm_gen` produces the sign-extended immediate in parallel.
4. **ALU-Source Select** — `alu_src_mux` picks the ALU's second operand: `read_data2` for `ADD`, or the immediate for `ADDI` — controlled by `ALUSrc` from `control_unit`.
5. **Execute** — `alu` computes `operand1 + operand2` (operation selected by `alu_control`'s `alu_opcode`).
6. **Write-Back** — the ALU's result is written directly back into `register_file` at address `rd`, gated by `RegWrite` from `control_unit`. Meanwhile, `pc_reg` increments by `4` on the same clock edge, ready for the next fetch.

### 🎬 ADD vs ADDI — the one real difference

| | `ADD rd, rs1, rs2` | `ADDI rd, rs1, imm` |
|---|---|---|
| ALU operand 2 source | Register file (`rs2`) | Sign-extended immediate |
| `ALUSrc` | `0` | `1` |
| Everything else (fetch, decode, ALU op, write-back) | **Identical** | **Identical** |

This is the entire reason `alu_src_mux` exists — a single control bit reroutes one wire, and the rest of the datapath doesn't need to know or care which instruction is executing.

---

## 5. 📁 Project Structure (File Hierarchy)

```
riscv-single-cycle-cpu/
│
├── register_file.v          # 32×32 register file (2 read ports, 1 write port, x0 hardwired to 0)
├── tb_register_file.v       # Standalone testbench — register_file.v
│
├── alu.v                    # ALU_RISCV — 8-operation combinational ALU
├── tb_alu.v                 # Standalone testbench — alu.v
│
├── imm_gen.v                # Sign-extends the 12-bit I-type immediate to 32 bits
├── tb_imm_gen.v             # Standalone testbench — imm_gen.v
│
├── control_unit.v           # Decodes opcode → RegWrite, ALUSrc
├── tb_control_unit.v        # Standalone testbench — control_unit.v
│
├── alu_control.v            # Decodes opcode/funct3/funct7 → alu_opcode
├── tb_alu_control.v         # Standalone testbench — alu_control.v
│
├── pc_reg.v                 # Program counter — resets to 0, increments by 4
├── tb_pc_reg.v              # Standalone testbench — pc_reg.v
│
├── instr_mem.v              # Combinational instruction memory (64 words)
├── tb_instr_mem.v           # Standalone testbench — instr_mem.v
│
├── alu_src_mux.v            # 2:1 mux — selects register value vs immediate for the ALU
├── tb_alu_src_mux.v         # Standalone testbench — alu_src_mux.v
│
├── riscv_core.v             # 🔝 Top-level module — instantiates & wires all 8 modules above
├── tb_riscv_core.v          # 🔝 Full-system testbench — loads a 5-instruction program & checks results
│
├── schematic.png            # Full datapath schematic / block diagram
├── io_wave.png               # Exported waveform screenshot from GTKWave
└── dump.vcd                 # Waveform dump generated after running any testbench
```

**Total: 21 files** — 9 core modules + 9 matching testbenches (18 files) + 3 supporting artifacts (schematic, waveform image, VCD dump).

---

## 6. 📂 Module-by-Module Breakdown

---

### `pc_reg.v` — Program Counter

Holds the address of the instruction currently being fetched.

| Port | Direction | Width | Description |
|---|---|---|---|
| `pc_out` | output reg | 32-bit | Current program counter value |
| `rst` | input | 1-bit | Synchronous reset — sets PC to 0 |
| `clk` | input | 1-bit | Clock |

**Behavior:** On reset, `pc_out` goes to `0`. Otherwise, on every rising clock edge, `pc_out` increments by **4** (not 1) — since RISC-V is byte-addressed and every instruction occupies 4 bytes.

---

### `instr_mem.v` — Instruction Memory

Stores the program and combinationally returns the instruction word at the requested address.

| Port | Direction | Width | Description |
|---|---|---|---|
| `instruction` | output | 32-bit | Instruction word at `pc_addr` |
| `pc_addr` | input | 32-bit | Byte address from `pc_reg` |

**Behavior:** Internally a `reg [31:0] mem [0:63]` array. `assign instruction = mem[pc_addr[31:2]]` — dropping the bottom 2 bits converts the byte address into a word index, since every instruction is 4 bytes wide. No `initial` block — the program is loaded externally by the testbench via hierarchical references (`uut.A2.mem[0] = ...`), just like real firmware pre-loaded into ROM before reset.

---

### `register_file.v` — 32×32 Register File

The CPU's general-purpose register bank.

| Port | Direction | Width | Description |
|---|---|---|---|
| `read_data1` | output | 32-bit | Value read from `rs1` |
| `read_data2` | output | 32-bit | Value read from `rs2` |
| `write_data` | input | 32-bit | Value to write into `rd` |
| `rd`, `rs1`, `rs2` | input | 5-bit each | Register addresses |
| `RegWrite` | input | 1-bit | Write enable |
| `rst` | input | 1-bit | Synchronous reset — clears all 32 registers |
| `clk` | input | 1-bit | Clock |

**Behavior:** Reads are combinational (`assign`), writes are clocked (`always @(posedge clk)`), and **`x0` is hardwired to always read as 0** regardless of what's stored internally — a strict RISC-V spec requirement.

---

### `imm_gen.v` — Immediate Generator

Extracts and sign-extends the 12-bit I-type immediate.

| Port | Direction | Width | Description |
|---|---|---|---|
| `imm_out` | output | 32-bit | Sign-extended immediate |
| `instruction` | input | 32-bit | Full instruction word |

**Behavior:** `assign imm_out = {{20{instruction[31]}}, instruction[31:20]};` — replicates the immediate's sign bit (`instruction[31]`) across the upper 20 bits, correctly handling both positive and negative immediates (verified against `ADDI x4, x3, -3` in testing).

---

### `control_unit.v` — Main Control Unit

Decodes the opcode into datapath control signals.

| Port | Direction | Width | Description |
|---|---|---|---|
| `RegWrite` | output | 1-bit | Enables register file write-back |
| `ALUSrc` | output | 1-bit | `0` = ALU operand2 from register, `1` = from immediate |
| `opcode` | input | 7-bit | `instruction[6:0]` |

**Behavior:** `RegWrite = 1` for both `ADD` (`0110011`) and `ADDI` (`0010011`) — both instructions write to `rd`. `ALUSrc = 1` only for `ADDI`, routing the immediate through the mux instead of `rs2`.

---

### `alu_control.v` — ALU Control

Resolves the exact ALU operation from opcode + funct3 + funct7.

| Port | Direction | Width | Description |
|---|---|---|---|
| `alu_opcode` | output reg | 3-bit | Operation code fed to `alu` |
| `opcode` | input | 7-bit | Instruction opcode |
| `funct3` | input | 3-bit | Instruction funct3 field |
| `funct7` | input | 7-bit | Instruction funct7 field |

**Behavior:** For R-type opcode (`0110011`) with `funct3=000`, disambiguates `ADD` vs `SUB` using `funct7` (`0000000` vs `0100000`). For I-type opcode (`0010011`), always outputs `ADD`'s code, since `ADDI` has no `funct7` field.

---

### `alu.v` (module `ALU_RISCV`) — Arithmetic Logic Unit

The computational core — fully combinational, 8 operations wired in for extensibility.

| Port | Direction | Width | Description |
|---|---|---|---|
| `result` | output | 32-bit | Computation result |
| `operand1`, `operand2` | input | 32-bit each | ALU inputs |
| `alu_opcode` | input | 3-bit | Selects operation |

**Supported operations:**

| `alu_opcode` | Operation |
|---|---|
| `000` | ADD |
| `001` | SUB |
| `010` | AND |
| `011` | OR |
| `100` | XOR |
| `101` | SLT |
| `110` | SLL |
| `111` | SRL |

Only `ADD` (and `SUB`, for extensibility) are actually exercised by this project's instruction subset — the rest are wired in and ready for when the instruction set is expanded.

---

### `alu_src_mux.v` — ALU Operand-2 Selector

The 2:1 mux that implements the `ADD`/`ADDI` distinction.

| Port | Direction | Width | Description |
|---|---|---|---|
| `operand2` | output | 32-bit | Selected ALU second operand |
| `read_data2` | input | 32-bit | Value from register file (`rs2`) |
| `imm_out` | input | 32-bit | Sign-extended immediate from `imm_gen` |
| `ALUsrc` | input | 1-bit | Select line from `control_unit` |

**Behavior:** `assign operand2 = ALUsrc ? imm_out : read_data2;`

---

### `riscv_core.v` — Top-Level Core 🔝

Instantiates and wires together all 8 modules above into the complete single-cycle datapath.

| Port | Direction | Width | Description |
|---|---|---|---|
| `rst` | input | 1-bit | Global reset |
| `clk` | input | 1-bit | Global clock |

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

This module contains **no logic of its own** — purely instantiation and wiring, plus instruction-field bit-slicing (`opcode`, `rd`, `rs1`, `rs2`, `funct3`, `funct7`) via `assign` statements.

---

### `tb_riscv_core.v` — Full-System Testbench 🔝

Drives the entire core end-to-end: generates the clock, pulses reset, hand-loads a 5-instruction test program directly into `instr_mem` via hierarchical references (`uut.A2.mem[...]`), lets the CPU run for several clock cycles, then reads back and displays every register's final value through `uut.A5.Reg[...]` to verify correctness against expected results.

---

## 7. 🧪 Test Program Used for Verification

```asm
addi x1, x0, 5      # x1 = 5
addi x2, x0, 10     # x2 = 10
add  x3, x1, x2     # x3 = 15
addi x4, x3, -3     # x4 = 12   (tests negative immediate / sign-extension)
add  x5, x4, x4     # x5 = 24
```

| Instruction | Hex encoding |
|---|---|
| `addi x1, x0, 5`  | `0x00500093` |
| `addi x2, x0, 10` | `0x00A00113` |
| `add x3, x1, x2`  | `0x002081B3` |
| `addi x4, x3, -3` | `0xFFD18213` |
| `add x5, x4, x4`  | `0x004202B3` |

This exercises basic `ADDI`, register-to-register `ADD`, chained data dependencies (x3 feeding into x4), and negative-immediate sign-extension — a small but meaningful smoke test for the full datapath.

---

## 8. ⚙️ How to Run This Project

### 8.1 🧩 Using VS Code + Icarus Verilog + GTKWave

**Requirements:**
- [VS Code](https://code.visualstudio.com/) with the *Verilog-HDL/SystemVerilog* extension (optional, for syntax highlighting)
- [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog`, `vvp`)
- [GTKWave](http://gtkwave.sourceforge.net/)

**Install (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install iverilog gtkwave
```

**Install (macOS, Homebrew):**
```bash
brew install icarus-verilog gtkwave
```

**Install (Windows):** Download the installer from [bleyer.org/icarus](http://bleyer.org/icarus/) (bundles `iverilog`, `vvp`, and GTKWave), or use WSL and follow the Ubuntu steps above.

**Step 1 — Compile the full-system testbench with all modules:**
```bash
iverilog -o tb_riscv_core.out tb_riscv_core.v riscv_core.v pc_reg.v instr_mem.v register_file.v imm_gen.v control_unit.v alu_control.v alu_src_mux.v alu.v
```

**Step 2 — Run the simulation:**
```bash
vvp tb_riscv_core.out
```

**Step 3 — View the waveform:**
```bash
gtkwave dump.vcd
```

> 💡 To test an individual module in isolation (e.g. just the ALU), compile its matching testbench instead:
> ```bash
> iverilog -o tb_alu.out tb_alu.v alu.v
> vvp tb_alu.out
> ```

---

### 8.2 🏗️ Using Xilinx Vivado

1. Open Vivado → **Create Project** → choose *RTL Project*.
2. **Add Sources** → add all 9 `.v` module files (`pc_reg.v`, `instr_mem.v`, `register_file.v`, `imm_gen.v`, `control_unit.v`, `alu_control.v`, `alu_src_mux.v`, `alu.v`, `riscv_core.v`) as **Design Sources**.
3. Add `tb_riscv_core.v` as a **Simulation Source** (right-click → *Add Sources* → *Add or Create Simulation Sources*).
4. Set `tb_riscv_core` as the **top module for simulation** (right-click it → *Set as Top*).
5. Run **Behavioral Simulation** (Flow Navigator → *Run Simulation* → *Run Behavioral Simulation*).
6. Use Vivado's built-in waveform viewer to inspect signals, or add the ones listed below.
7. (Optional) For synthesis, set `riscv_core` (not the testbench) as the **top module for synthesis**, then run **Synthesis** and **Implementation** from the Flow Navigator to see resource utilization / generate a bitstream for an FPGA target.

**Recommended signals to add to any waveform viewer:**
- `clk`, `rst`
- `uut.pc_out` — program counter
- `uut.instr` — current instruction
- `uut.alu_result` — ALU output
- `uut.A5.Reg[1]` through `uut.A5.Reg[5]` — register values

---

## 9. 🖥️ Sample Simulation Output

```
---- Final Register Values ----
x1 = 5  (expected 5)
x2 = 10 (expected 10)
x3 = 15 (expected 15)
x4 = 12 (expected 12)
x5 = 24 (expected 24)
```

📸 See `io_wave.png` for the corresponding GTKWave waveform screenshot, and `schematic.png` for the full block-level datapath diagram.

---

## 10. 🔑 Key Design Decisions

**Why single-cycle instead of a shared-bus multi-cycle design?**
Single-cycle execution matches how RV32I's fixed-length, cleanly-fielded instruction format is meant to be used — every instruction fully executes in one clock edge, with no shared bus arbitration needed, unlike bus-based designs (e.g. SAP-1-style CPUs) that require multiple cycles per instruction.

**Why separate `control_unit` and `alu_control` instead of one big decoder?**
Mirrors real CPU design practice — `control_unit` handles datapath-wide signals (`RegWrite`, `ALUSrc`), while `alu_control` handles ALU-specific operation selection. This separation keeps each module focused and makes it trivial to extend `alu_control` alone when adding new ALU operations, without touching the rest of the control logic.

**Why is `x0` hardwired to zero at the read output, not blocked at the write?**
Forcing the *read* path (`(rs1 == 0) ? 0 : Reg[rs1]`) guarantees correctness regardless of what internally happens to `Reg[0]` — simpler and more robust than trying to prevent the write in the first place.

**Why include unused ALU operations (`SUB`, `AND`, `OR`, etc.) now?**
Zero cost today, and it means extending the instruction set later is purely a `control_unit`/`alu_control` change — the ALU itself doesn't need to be touched again.

**Why is the immediate generator its own separate module?**
Keeps sign-extension logic isolated and independently testable, and mirrors how a real RV32I core needs separate immediate-generation logic per instruction format (I/S/B/U/J) — this project currently handles I-type only, but the module boundary is already in the right place to extend.

---

## 11. 🚧 Current Limitations & Future Roadmap

This is a deliberately minimal starting point. Planned extensions:

- [ ] Add remaining R-type instructions (`SUB`, `AND`, `OR`, `XOR`, `SLT`, shifts) — ALU already supports these, only `control_unit`/`alu_control` wiring needs extending
- [ ] Add I-type logic instructions (`ANDI`, `ORI`, `XORI`, `SLTI`)
- [ ] Add `LOAD`/`STORE` support — requires a data memory module and `MemRead`/`MemWrite`/`MemtoReg` control signals
- [ ] Add branch instructions (`BEQ`, `BNE`, etc.) — requires a branch comparator and PC-relative addressing
- [ ] Add `JAL`/`JALR` for jumps and function calls
- [ ] Add hazard handling if/when this evolves into a pipelined (rather than single-cycle) design

---

## 12. 👤 Author

Built module-by-module, bug-by-bug, from a blank file to a working RISC-V core — with every single line reviewed, debugged, and understood along the way rather than copy-pasted. 🛠️

Feel free to fork, ⭐ star, and extend this with more of the RV32I instruction set. Pull requests and issues welcome!

---

## 13. 📄 License

MIT License — free to use, modify, and distribute with attribution.
