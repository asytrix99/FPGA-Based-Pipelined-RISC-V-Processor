# CG3207 Assignment 4


## Folder structure
```text
Asst_04/
│
├── Src/
│   ├── AA_DMEM.mem
│   ├── AA_IROM.mem
│   ├── ADXL362Ctrl.vhd
│   ├── ALU.v
│   ├── Branch_Prediction.v
│   ├── Decoder.v
│   ├── Extend.v
│   ├── MCycle.v
│   ├── PC_Logic.v
│   ├── pmodoledrgb_bitmap.vhd
│   ├── ProgramCounter.v
│   ├── RegFile.v
│   ├── RV.v
│   ├── Shifter.v
│   ├── SPI_If.vhd
│   ├── TOP_Nexys.vhd
│   ├── uart.vhd
│   └── Wrapper.v
│
├── Test_bench/
│   ├── tb_ALU.v
│   ├── tb_Branch_Predicition.v
│   ├── tb_Decoder.v
│   ├── tb_MCycle.v
│   ├── tb_MCycle_self_checking.v
│   ├── tb_PC_Logic.v
│   ├── tb_RV.v
│   └── test_Wrapper.v
│
├── Code/
│   ├── bench.c
│   ├── bench.asm
│   └── bench_results.md
│
│
├── Timing Reports/
│   ├── TOP_timing_summary_routed_non-pipelined.rpt
│   ├── TOP_timing_summary_routed_pipelined_no_prediction.rpt
│   └── TOP_timing_summary_routed_pipelined_prediction.rpt
│
├── bitstream/
│   └── Top.bit
│
├── Constraint/
│   ├── Nexys-A7-100T-Master.xdc
│   ├── TOP_Nexys4.xdc
│   └── TOP_Nexys4DDR.xdc
│
├── Enhancement.pptx
│
└── README.md
```

## Files changed
### RTL Source Files
- `Decoder.v`
   - Implements the Decoder logic for mulh, mulhu, rem and remu.
- `RV.v`
   - Selects the appropriate MCycle output based on decoder control signals: lower or upper product for multiplication, and quotient or remainder for division.
   - Supports `lb` / `lbu` / `lh` / `lhu` through byte/half-word selection and sign/zero extension in Writeback.
   - Supports `sb` / `sh` through store-data alignment and byte write enables.
   - Implements a five-stage pipeline: Fetch, Decode, Execute, Memory and Writeback.
   - Implements M-to-E, W-to-E, W-to-D and W-to-M forwarding.
   - Handles load-use hazards by holding Fetch and Decode and inserting a bubble into Execute.
   - Holds Fetch, Decode and Execute while the multicycle unit is busy.
   - Integrates branch prediction and redirects the PC and flushes wrong-path instructions on a misprediction.
- `MCycle.v`
  - Provides the upper 32 bits of the multiplication result for `mulh` / `mulhu`, and the remainder for `rem` / `remu`.
- `Branch_Prediction.v`
   - Predicts the next PC in the Fetch stage, using a 64-entry branch target buffer with 2-bit counters
- `TOP_Nexys.vhd`
   - CPU clock from the Clocking Wizard (`clk_wiz_0`) instead of the clock divider. See [Clock](#clock)

### Testbench Files
- `tb_Branch_Prediciton`
    - Test bench for Branch_Prediction.v

### Software
- #### `bench.c`
    C benchmark used for the Assignment 4 demonstration, to compare the single-cycle CPU and the pipelined CPU with
    branch prediction. See [Benchmark Program](#benchmark-program).

- #### `bench.asm`
    RISC-V assembly generated from `bench.c` using [Godbolt Compiler Explorer](https://godbolt.org/) with
    `RISC-V rv32gc clang 20.1.0` and `-DCLK_PERIOD_PS=<period>` matching the bitstream. Zero-initialised arrays
    are emitted as `.zero N`, which is replaced by `.space N` for RARS.

- #### `bench_results.md`
    Board measurements of `bench.c` on the single-cycle CPU at 40 MHz and the pipelined CPU with branch prediction at
    50 MHz: cycle counts, timing and time. Also compares the pipelined CPU with the predictor on and off.

### Others
- #### `Enhancement.pptx`
    Presentation slides describing the implemented enhancements.

## Benchmark Program
`bench.c` runs one of 4 workloads, chosen by the DIP switches. Each one stresses a different pipeline hazard,
and the result is checked by a second method, so a hazard bug shows up as a FAIL. The cycle counter times only
the workload, so the same program can be compared on the single-cycle and the pipelined CPU.

| SW1-SW0 | Workload | Stresses |
|---|---|---|
| 0 | `FIBI` iterative Fibonacci | back-to-back dependent adds (forwarding), loop branches (prediction) |
| 1 | `FIBR` recursive Fibonacci | `jal` / `jalr`, stack loads and stores (load-use stall) |
| 2 | `FIBT` Fibonacci table in data memory | store then load of the same data |
| 3 | `PRIM` prime count by trial division | `mul` and `remu` on MCycle (stall) |

- **SW7-SW2:** n (at most 39 for `FIBI`/`FIBT`, 24 for `FIBR`; `PRIM` counts primes up to n * 16)
- **SW14:** sweep, runs the selected workload for every n from 1 to its maximum (one UART line each), ignoring SW7-SW2
- **SW15:** seven-segment display shows the result (off) or the time in us (on), in decimal
- **Pushbuttons:** run again. The benchmark also runs at start-up and whenever a switch changes
- **LEDs:** LED0 = PASS, LED1 = FAIL, LED3-2 = workload
- **UART:** one line per run, e.g. `FIBI N=39 R=63245986 CYC=820 NS=16400 PASS` (pipelined with branch prediction, 50 MHz)

Only `int` data is used, so there are no `sb` / `sh` and the program also runs on the Assignment 3 CPU.

> `_start()` must stay the first function in `bench.c`. It sets `sp` before `main()` builds its stack frame.
> Setting `sp` inside `main()` is too late: the compiler may address `main`'s locals through `s0`, which is
> computed from `sp` = 0, and the program then writes nothing to the outputs.

### Clock
`TOP_Nexys.vhd` takes the CPU clock from a Clocking Wizard IP, which is not in the repository. Add it to the
Vivado project (IP Catalog > Clocking Wizard) with:
- **Component name:** `clk_wiz_0`
- **Input:** 100 MHz, source = Global buffer
- **`clk_out1`:** 100 MHz, for the UART, seven-segment display, OLED and accelerometer
- **`clk_out2`:** the CPU clock, from the table below

Both builds meet timing at these clocks, including the paths between the CPU and the peripherals. Compile `bench.c`
with the matching period, so that `NS=` is correct:

| CPU | `clk_out2` | Godbolt compiler options |
|---|---|---|
| Single-cycle (Assignment 3) | 40 MHz | `-DCLK_PERIOD_PS=25000` |
| Pipelined with branch prediction | 50 MHz | `-DCLK_PERIOD_PS=20000` |

Without `CLK_PERIOD_PS`, `bench.c` falls back to `CLK_DIV_BITS` (default 1, 25 MHz) for the old clock divider,
where the CPU clock is 100 MHz / 2^(CLK_DIV_BITS + 1), or 100 MHz when `CLK_DIV_BITS` = 0.


