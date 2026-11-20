# FPGA setup and simulation

## Tools and hardware

- Xilinx Vivado with Artix-7 device support. The exact version used for the recorded board results is not documented; source-header version labels are not proof of the final build version.
- An appropriate Nexys board with an XC7A100T-CSG324-1 FPGA and a 100 MHz input clock. The repository contains constraints for Nexys 4, Nexys 4 DDR, and Nexys A7-100T; select the file for your physical board.
- Icarus Verilog (`iverilog` and `vvp`) for the standalone Verilog testbenches.
- For rebuilding benchmark software: the recorded compiler is RISC-V rv32gc clang 20.1.0 on Compiler Explorer, followed by RARS assembly/memory export. The repository does not yet contain a complete automated C-to-memory-image toolchain.

## Create the Vivado project

1. Clone your authorised private checkout, then change into its local directory. For example, cloning the original repository uses `git clone https://github.com/asytrix99/CG3207.git` followed by `cd CG3207`; select the branch containing Assignment 4 because the original default branch may contain only documentation. This cleaned checkout already contains `Asst_04/`.
2. Create an RTL project **outside this Git checkout**. Select part `xc7a100tcsg324-1`, with Verilog as the target language and mixed-language simulation if needed.
3. Add **all `.v` and `.vhd` files** under `Asst_04/Src/` as design sources. Reference the original files instead of copying them into the project. Set the synthesis top to **`TOP`**, the entity in `TOP_Nexys.vhd`.
4. Add `AA_IROM.mem` and `AA_DMEM.mem` from the same directory as memory initialization files. `Wrapper.v` loads these exact basenames with `$readmemh`; make sure Vivado includes them in the build's working directory.
5. Add **one** board constraint file:

   | Physical board | Constraint file under `Asst_04/Constraint/` |
   | --- | --- |
   | Nexys A7-100T | `Nexys-A7-100T-Master.xdc` |
   | Nexys 4 | `TOP_Nexys4.xdc` |
   | Nexys 4 DDR | `TOP_Nexys4DDR.xdc` |

   Do not enable all three simultaneously. Check pin assignments and peripheral connections against your board before programming.
6. Create the Clocking Wizard IP described below and generate its output products.
7. Run synthesis and implementation, review warnings and timing, and generate the bitstream. Record your tool version and build configuration. The committed `bitstream/TOP.bit` is a historical demo artifact; its presence is not verification of a new build.
8. Open Hardware Manager, connect the board, and program the generated bitstream. Use UART at **115200 baud** and the [benchmark controls](../Asst_04/README.md#benchmark-program) to check results.

## Required Clocking Wizard IP

The generated IP is not committed. In IP Catalog → Clocking Wizard, create:

| Setting | Value |
| --- | --- |
| Component name | `clk_wiz_0` |
| Input port / frequency | `clk_in1`, 100 MHz, global buffer source |
| Output 1 | `clk_out1`, 100 MHz (peripherals) |
| Output 2 | `clk_out2`, 50 MHz (pipelined CPU) |
| Control/status ports | Active-high `reset` input and `locked` output |

The VHDL component declaration expects those exact ports. Both predictor-enabled and predictor-disabled pipeline measurements use 50 MHz. The historical single-cycle baseline uses the divider at 25 MHz.

## Run the Verilog testbenches

From the repository root:

```sh
bash scripts/run_tests.sh
```

The script compiles each bench independently and writes logs and waveforms to a temporary directory printed at startup. It checks the text output because the existing benches can report failures without a nonzero simulator exit status.

| Testbench top | Scope |
| --- | --- |
| `tb_ALU` | ALU operations |
| `tb_Decoder` | Instruction decoding |
| `tb_PC_Logic` | PC control |
| `tb_Branch_Prediction` | Prediction and predictor updates |
| `test_MCycle` (file `tb_MCycle_self_checking.v`) | Multicycle arithmetic |
| `tb_RV` | Processor instruction and memory-operation checks |


To run one automated bench manually from the repository root:

```sh
iverilog -g2012 -s tb_RV -o /tmp/cg3207-tb_RV.vvp Asst_04/Test_bench/tb_RV.v Asst_04/Src/*.v
vvp /tmp/cg3207-tb_RV.vvp
```

This writes `tb_RV.vcd` in the current directory. In Vivado, add the desired bench under **Simulation Sources**, set its module as simulation top, and run behavioural simulation. These benches exercise Verilog components, not the complete mixed-language FPGA top or Clocking Wizard. Passing them does not establish complete ISA compliance or FPGA timing closure.

## Benchmark software and baseline

Use the committed `.mem` files for the supplied program. If rebuilding `bench.c`, retain the recorded `-O0` setting and use `-DCLK_PERIOD_PS=20000` for 50 MHz or `-DCLK_PERIOD_PS=40000` for 25 MHz. The recorded assembly workflow replaces `.zero N` with `.space N` for RARS. Startup code, memory addresses, stack placement, and exported instruction/data images must match `Wrapper.v`; a complete export recipe is not recorded, so this guide does not claim a one-command software rebuild.