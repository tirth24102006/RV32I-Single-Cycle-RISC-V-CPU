## RV32I Single-Cycle RISC-V CPU 

A minimal single-cycle 32-bit RISC-V (RV32I) CPU built from scratch in Verilog HDL, executing ADD and ADDI. Fully modular datapath — PC, instruction memory, register file, ALU, control unit, ALU control, immediate generator, and ALU-source mux — each with its own testbench, simulated in Icarus Verilog and visualized in GTKWave & Vivado. 🚀

---

# 🧠 RV32I Single-Cycle RISC-V CPU (ADD / ADDI Subset)

### Built from scratch in Verilog HDL

> ⚙️ A fully modular, single-cycle 32-bit RISC-V processor, hand-built in Verilog HDL from the ground up — implementing the `ADD` and `ADDI` instructions from the RV32I base integer instruction set. Every stage of the classic **Fetch → Decode → Execute → Write-Back** pipeline is broken into its own clean, independently testable module. Simulated with Icarus Verilog, inspected in GTKWave, and synthesizable in Xilinx Vivado. 🚀

> 🔨 **Status:** Actively in progress — the core currently supports `ADD`/`ADDI` and is fully verified. More of the RV32I instruction set (branches, loads/stores, remaining ALU ops) is being added incrementally. See the [roadmap](#13--current-limitations--roadmap) below.

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
13. [Current Limitations & Roadmap](#13--current-limitations--roadmap)
14. [Key Design Decisions](#14--key-design-decisions)
15. [Author](#15--author)
16. [License](#16--license)

---

## 1. 📌 Project Highlights

- ✅ Fully working **single-cycle 32-bit RISC-V datapath**, built entirely from first principles
- ✅ Implements real **RV32I** encoding — `ADD` (R-type) and `ADDI` (I-type), matching the official RISC-V ISA spec bit-for-bit
- ✅ **9 independent hardware modules**, each with its own dedicated testbench (18 files total)
- ✅ Working **32×32 register file** with `x0` hardwired to zero, exactly as the spec requires
- ✅ Combinational **instruction memory** with correct byte-to-word address translation
- ✅ Extensible **8-operation ALU** (only `ADD`/`SUB` are exercised today, rest are ready for later)
- ✅ Proper **sign-extended immediate generation**, tested against negative immediates
- ✅ Clean separation of **control logic** from the **datapath** — the same principle real CPUs use
- ✅ Full-system testbench that loads a 5-instruction program and verifies every register
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

RV32I contains roughly **47 base instructions**. This project deliberately implements a minimal subset — just **`ADD`** and **`ADDI`** — to prove out the entire datapath end-to-end before scaling up to the full instruction set.

---

## 3. 🔍 Instruction Encoding — R-type & I-type

Every RISC-V instruction is a fixed **32 bits wide**. Our two instructions use these formats:

**R-type** (`ADD`)

```
 31        25 24     20 19     15 14    12 11      7 6        0
┌────────────┬─────────┬─────────┬────────┬──────────┬─────────┐
│   funct7   │   rs2   │   rs1   │ funct3 │    rd    │  opcode │
└────────────┴─────────┴─────────┴────────┴──────────┴─────────┘
```

**I-type** (`ADDI`)

```
 31                  20 19     15 14    12 11      7 6        0
┌──────────────────────┬─────────┬────────┬──────────┬─────────┐
│      imm[11:0]       │   rs1   │ funct3 │    rd    │  opcode │
└──────────────────────┴─────────┴────────┴──────────┴─────────┘
```

**Encoding table for the instructions used in this project:**

| Instruction | opcode | funct3 | funct7 | Notes |
|---|---|---|---|---|
| `ADD`  | `0110011` | `000` | `0000000` | R-type — reads `rs1` & `rs2` |
| `SUB`  | `0110011` | `000` | `0100000` | R-type — wired in for extensibility, not used yet |
| `ADDI` | `0010011` | `000` | — | I-type — reads `rs1` + 12-bit sign-extended immediate |

> 🧾 **Sign extension:** the 12-bit `imm[11:0]` field is extended to 32 bits by replicating bit `[31]` of the instruction across bits `[31:12]` — implemented as `{{20{instruction[31]}}, instruction[31:20]}`.

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
| **5. Execute** | `alu` computes `operand1 + operand2` (operation chosen by `alu_control`) |
| **6. Write-Back** | The ALU's result is written into `register_file` at address `rd`, gated by `RegWrite`. `pc_reg` increments by `4` on the same edge, ready for the next fetch |

### ADD vs ADDI — the one real difference

| | `ADD rd, rs1, rs2` | `ADDI rd, rs1, imm` |
|---|---|---|
| ALU operand 2 source | Register file (`rs2`) | Sign-extended immediate |
| `ALUSrc` | `0` | `1` |
| Everything else | **Identical** | **Identical** |

A single control bit reroutes one wire — the rest of the datapath doesn't need to know or care which instruction is executing.

---

## 5. 🧩 How the Whole CPU Works — End-to-End Walkthrough

This section ties every module together by tracing **one real instruction, all the way through the hardware**, then zooming out to show how all 5 instructions of the test program run back-to-back.

### 🔬 Tracing a single instruction: `add x3, x1, x2`

Assume `x1 = 5` and `x2 = 10` already sit in the register file (from the two `ADDI`s that ran before this one). Here is exactly what happens, module by module, in the one clock cycle this instruction takes to execute:

| Step | Module involved | What happens |
|---|---|---|
| ① | `pc_reg` | `pc_out = 8` (this is the 3rd instruction — byte address `8`, since each instruction is 4 bytes) |
| ② | `instr_mem` | `pc_addr[31:2]` = word index `2` → returns `mem[2] = 0x002081B3` on the `instruction` wire |
| ③ | Bit-slicing (inside `riscv_core`) | `opcode = 0110011`, `rd = 00011` (x3), `funct3 = 000`, `rs1 = 00001` (x1), `rs2 = 00010` (x2), `funct7 = 0000000` |
| ④ | `control_unit` | Sees `opcode = 0110011` → outputs `RegWrite = 1`, `ALUSrc = 0` |
| ⑤ | `alu_control` | Sees `opcode = 0110011`, `funct3 = 000`, `funct7 = 0000000` → outputs `alu_opcode = 000` (ADD) |
| ⑥ | `register_file` | Reads `rs1 = x1` → `read_data1 = 5`; reads `rs2 = x2` → `read_data2 = 10` |
| ⑦ | `imm_gen` | Also computes an immediate in parallel (`imm_out` = some value) — but it's irrelevant here, since... |
| ⑧ | `alu_src_mux` | `ALUSrc = 0` → passes `read_data2` (10) through as `operand2`, ignoring `imm_out` entirely |
| ⑨ | `alu` | Computes `operand1 + operand2` = `5 + 10` = **`15`**, using `alu_opcode = 000` (ADD) |
| ⑩ | `register_file` (write-back) | Because `RegWrite = 1`, on this same clock edge, `x3` is written with `alu_result = 15` |
| ⑪ | `pc_reg` | On the same clock edge, `pc_out` becomes `12`, pointing at the 4th instruction next |

**All eleven of those steps happen within a single clock cycle** — that's the entire point of a single-cycle design. Nothing here waits for a second clock edge; the moment the clock ticks, the whole chain above has already settled combinationally, and only `pc_reg`/`register_file` actually latch new values on that edge.

### 🎬 Running the full 5-instruction program, cycle by cycle

| Cycle | `pc_out` | Instruction fetched | What it does | Registers after this cycle |
|---|---|---|---|---|
| 1 | `0`  | `addi x1, x0, 5`  | `x1 = 0 + 5`   | `x1=5` |
| 2 | `4`  | `addi x2, x0, 10` | `x2 = 0 + 10`  | `x1=5, x2=10` |
| 3 | `8`  | `add  x3, x1, x2` | `x3 = 5 + 10`  | `x1=5, x2=10, x3=15` |
| 4 | `12` | `addi x4, x3, -3` | `x4 = 15 + (-3)` | `x1=5, x2=10, x3=15, x4=12` |
| 5 | `16` | `add  x5, x4, x4` | `x5 = 12 + 12` | `x1=5, x2=10, x3=15, x4=12, x5=24` |

Notice how **`x1` = `x0 + 5` uses the exact same hardware path as `x3` = `x1 + x2`** — the only thing that changes cycle to cycle is which bits happen to be sitting in the instruction word, which flip `ALUSrc`, change which registers get read, and change what gets written where. There is no special-case circuitry for "the first instruction" or "a constant-loading instruction" — `x0` being hardwired to zero is what lets `ADDI` double as a way to load constants, entirely for free.

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
├── schematic.png           # Full datapath schematic / block diagram
├── io_wave.png             # Exported waveform screenshot from GTKWave
└── dump.vcd                # Waveform dump, generated after running any testbench
```

**Total: 21 files** — 9 core modules + 9 matching testbenches (18 files) + 3 supporting artifacts.

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

`RegWrite = 1` for both `ADD` and `ADDI`. `ALUSrc = 1` only for `ADDI`.

---

### `alu_control.v` — ALU Control

| Port | Direction | Width | Description |
|---|---|---|---|
| `alu_opcode` | output reg | 3-bit | Operation code fed to `alu` |
| `opcode` | input | 7-bit | Instruction opcode |
| `funct3` | input | 3-bit | Instruction funct3 field |
| `funct7` | input | 7-bit | Instruction funct7 field |

Disambiguates `ADD` vs `SUB` using `funct7` for R-type; always outputs `ADD`'s code for I-type `ADDI`.

---

### `alu.v` (module `ALU_RISCV`) — Arithmetic Logic Unit

| Port | Direction | Width | Description |
|---|---|---|---|
| `result` | output | 32-bit | Computation result |
| `operand1` / `operand2` | input | 32-bit each | ALU inputs |
| `alu_opcode` | input | 3-bit | Selects operation |

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

Only `ADD` (and `SUB`, for extensibility) are exercised today — the rest are wired in for when the instruction set expands.

---

### `alu_src_mux.v` — ALU Operand-2 Selector

| Port | Direction | Width | Description |
|---|---|---|---|
| `operand2` | output | 32-bit | Selected ALU second operand |
| `read_data2` | input | 32-bit | Value from register file (`rs2`) |
| `imm_out` | input | 32-bit | Sign-extended immediate |
| `ALUsrc` | input | 1-bit | Select line from `control_unit` |

The 2:1 mux that implements the entire `ADD`/`ADDI` distinction.

---

### `riscv_core.v` — Top-Level Core 🔝

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

Contains no logic of its own — purely instantiation, wiring, and instruction-field bit-slicing.

---

### `tb_riscv_core.v` — Full-System Testbench 🔝

Generates the clock, pulses reset, hand-loads a 5-instruction test program directly into `instr_mem` (`uut.A2.mem[...]`), lets the CPU run for several cycles, then reads back and displays every register's final value (`uut.A5.Reg[...]`) to verify correctness.

---

## 8. 🧪 Test Program Used for Verification

```asm
addi x1, x0, 5      # x1 = 5
addi x2, x0, 10     # x2 = 10
add  x3, x1, x2     # x3 = 15
addi x4, x3, -3     # x4 = 12   (negative immediate / sign-extension test)
add  x5, x4, x4     # x5 = 24
```

| Instruction | Hex encoding |
|---|---|
| `addi x1, x0, 5`  | `0x00500093` |
| `addi x2, x0, 10` | `0x00A00113` |
| `add x3, x1, x2`  | `0x002081B3` |
| `addi x4, x3, -3` | `0xFFD18213` |
| `add x5, x4, x4`  | `0x004202B3` |

Exercises basic `ADDI`, register-to-register `ADD`, chained data dependencies (x3 feeding into x4), and negative-immediate sign-extension.

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
7. Use Vivado's built-in waveform viewer — add `clk`, `rst`, `uut/pc_out`, `uut/instr`, and `uut/A5/Reg[1]` through `Reg[5]`.
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
```

📸 See `io_wave.png` for the corresponding GTKWave waveform screenshot, and `schematic.png` for the full block-level datapath diagram.

---

## 13. 🚧 Current Limitations & Roadmap

This project is a **deliberately minimal starting point** and is **still being actively extended**. Planned next steps:

- [ ] Add remaining R-type instructions (`SUB`, `AND`, `OR`, `XOR`, `SLT`, shifts) — the ALU already supports these; only `control_unit`/`alu_control` wiring needs extending
- [ ] Add I-type logic instructions (`ANDI`, `ORI`, `XORI`, `SLTI`)
- [ ] Add `LOAD`/`STORE` support — requires a data memory module and `MemRead`/`MemWrite`/`MemtoReg` control signals
- [ ] Add branch instructions (`BEQ`, `BNE`, etc.) — requires a branch comparator and PC-relative addressing
- [ ] Add `JAL`/`JALR` for jumps and function calls
- [ ] Consider hazard handling if this evolves into a pipelined (rather than single-cycle) design

---

## 14. 🔑 Key Design Decisions

**Single-cycle instead of a shared-bus multi-cycle design.** Matches how RV32I's fixed-length, cleanly-fielded format is meant to be used — every instruction fully executes in one clock edge, with no bus arbitration needed.

**Separate `control_unit` and `alu_control`.** Mirrors real CPU design practice — datapath-wide signals versus ALU-specific operation selection — keeping each module focused and easy to extend independently.

**`x0` hardwired at the read output, not blocked at the write.** `(rs1 == 0) ? 0 : Reg[rs1]` guarantees correctness regardless of what happens internally to `Reg[0]`.

**Unused ALU operations included now.** Zero cost today, and extending the instruction set later becomes purely a `control_unit`/`alu_control` change.

**`imm_gen` as its own module.** Keeps sign-extension logic isolated and independently testable, and mirrors how a real RV32I core needs separate immediate-generation logic per instruction format.

---

## 15. 👤 Author

Built module-by-module, bug-by-bug, from a blank file to a working RISC-V core — every line reviewed, debugged, and understood along the way rather than copy-pasted. 🛠️

Feel free to fork, ⭐ star, and extend this with more of the RV32I instruction set. Pull requests and issues welcome!

---

## 16. 📄 License

MIT License — free to use, modify, and distribute with attribution.

