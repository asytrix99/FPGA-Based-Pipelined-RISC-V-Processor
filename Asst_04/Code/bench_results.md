# Benchmark Results
Results of `bench.c` (see [README](../README.md#benchmark-program)) on two CPUs:

- **Single-cycle:** the last single-cycle `RV.v` (just before commit `f2de654`, the Assignment 3 CPU with `sb` and `sh`)
  at 25 MHz
- **Pipelined + BP:** the Assignment 4 pipelined CPU with branch prediction at 50 MHz

| CPU | Clock | Clock source | `-DCLK_PERIOD_PS` |
|---|---|---|---|
| Single-cycle | 25 MHz | Clock divider in `TOP_Nexys.vhd` (`CLK_DIV_BITS` = 1) | 40000 |
| Pipelined + BP | 50 MHz | Clocking Wizard (`clk_out2`) | 20000 |

The [effect of branch prediction](#effect-of-branch-prediction) section also uses a pipelined CPU without the
predictor, at 50 MHz.

## Cycle counts
Measured on the board, same `bench.c` for both CPUs. The cycle count does not depend on the clock. All runs PASS.

| Workload | n | Single-cycle CYC | Pipelined + BP CYC | Pipelined + BP / single-cycle |
|---|---|---|---|---|
| `FIBI` | 39 | 694 | 820 | 1.18 |
| `FIBR` | 24 | 3301089 | 3861695 | 1.17 |
| `FIBT` | 39 | 695 | 865 | 1.24 |
| `PRIM` | 1008 | 439424 | 465991 | 1.06 |

The pipelined CPU needs more cycles, since it loses cycles to hazards and the single-cycle CPU always takes 1 cycle
per instruction. For example, one `fib_iter` loop iteration is 17 instructions: 17 cycles on the single-cycle CPU, and
20 on the pipelined CPU (3 load-use stalls). The loop's 3 taken jumps cost no flush cycles once they are predicted
correctly.

`PRIM` has the smallest ratio because most of its time is spent waiting for MCycle, which takes the same number of
cycles on both CPUs. `bench.c` is compiled with `-O0`, where every variable is loaded from and stored to the stack, so
there are many more load-use stalls and taken jumps than in optimised code.

## Timing
From the Vivado timing reports of the builds that ran on the board.

| | Single-cycle | Pipelined + BP |
|---|---|---|
| Clock period | 40 ns | 20 ns |
| CPU clock WNS | 3.529 ns | 0.700 ns |
| Critical path (period - WNS) | 36.47 ns | 19.30 ns |
| Data path delay | 36.085 ns | 18.721 ns |
| Path start | `PC_reg[11]` | `ReadData_W_reg[4]` |
| Path end | `RegBank_reg_r1_0_31_30_31__0/DP/I` | `Instr_D_reg[15]/R` |

The single-cycle critical path runs from the PC to a register file write, while the pipelined critical path runs from
a W-stage register to the reset of a D-stage register.

The pipelined build meets all constraints. The single-cycle build does not: its CPU clock comes from the clock divider,
which the project does not declare as a clock, so Vivado's normal report covers only the 100 MHz peripheral logic (WNS
3.836 ns) and leaves 2805 CPU register pins with no clock. The single-cycle figures here come from declaring the clock
on the routed design, which analyses the same build that ran on the board:

```tcl
create_generated_clock -name clk_cpu -source [get_ports CLK_undiv] -divide_by 4 [get_pins CLK_DIVIDER_ON_SET.CLK_reg/Q]
```

Implementation never saw this clock, so it did not optimise the CPU paths. The 36.47 ns therefore says little about the
single-cycle CPU: an earlier build with the Clocking Wizard at 40 MHz had a critical path of 23.91 ns.

These critical paths cannot be used as f_max, because the tool stops optimising once a constraint is met.

Paths between the CPU clock and the 100 MHz peripheral clock:

| Path | Single-cycle | Pipelined + BP |
|---|---|---|
| CPU clock to 100 MHz, setup WNS | 2.772 ns | 5.258 ns |
| 100 MHz to CPU clock, setup WNS | 3.922 ns | 4.607 ns |
| 100 MHz to CPU clock, hold WHS | -1.013 ns (84 failing endpoints) | 0.126 ns |

The single-cycle hold failures are from the UART and accelerometer registers into the CPU. The divider delays the CPU
clock by about 3 ns relative to the 100 MHz logic, and implementation could not correct this without the clock being
declared. So timing does not guarantee this crossing. The CPU's own paths meet timing, and every run passed on the
board.

## Time on the board
All times are `NS=` from the board.

| Workload | n | Single-cycle time (ns) | Pipelined + BP time (ns) | Speedup |
|---|---|---|---|---|
| `FIBI` | 39 | 27760 | 16400 | 1.69 |
| `FIBR` | 24 | 132043560 | 77233900 | 1.71 |
| `FIBT` | 39 | 27800 | 17300 | 1.61 |
| `PRIM` | 1008 | 17576960 | 9319820 | 1.89 |

Run time is the number of cycles x the clock period, so the speedup depends on both:

```text
Speedup = single-cycle time / pipelined time
        = (single-cycle CYC x 40 ns) / (pipelined CYC x 20 ns)
        = 2 / (pipelined CYC / single-cycle CYC)
```

Pipelining splits each instruction across 5 stages, which allows a faster clock, but hazards add cycles. The pipelined
CPU is only faster overall when it needs less than 2x the cycles:

| Workload | Clock gain | Cycle ratio | Speedup | Reason |
|---|---|---|---|---|
| `FIBI` | 2 | 1.18 | 1.69 | The loop's jumps are easy to predict, so the main cost is load-use stalls from using values right after loading them from the stack |
| `FIBR` | 2 | 1.17 | 1.71 | Recursion is harder to predict, since the same `ret` goes back to different places and the base case check changes between calls. Stack loads also cause stalls |
| `FIBT` | 2 | 1.24 | 1.61 | Each entry is loaded from the table and used straight away, which adds another load-use stall to the loop, so it keeps the least of the clock gain |
| `PRIM` | 2 | 1.06 | 1.89 | `mul` and `remu` wait for MCycle on both CPUs, so hazards are a small part of the run time, and those waits finish sooner on the faster clock |

The 2x clock gain comes from the clocks chosen here, not from a measured f_max for each CPU. An earlier single-cycle
build also passed every run at 40 MHz with the same cycle counts. Against that build the speedups are only 1.06
(`FIBI`), 1.07 (`FIBR`), 1.00 (`FIBT`) and 1.18 (`PRIM`).

The pipelined CPU is faster at every n measured. The speedup is lowest at small n:

| Workload | n measured | Lowest speedup | Speedup at largest n |
|---|---|---|---|
| `FIBI` | 1 to 39 | 1.60 (n = 1) | 1.69 |
| `FIBR` | 1 to 24 | 1.53 (n = 1) | 1.71 |
| `FIBT` | 1 to 39 | 1.50 (n = 2) | 1.61 |
| `PRIM` | 16 to 1008 | 1.82 (n = 16) | 1.89 |

The `FIBI` row is for a trained predictor. Reset clears the predictor, and later runs keep what it has learned. In the
first of two `FIBI` sweeps, n = 1 and 2 took 64 and 82 cycles instead of 60 and 80, which lowers the speedup at n = 1
to 1.50. From n = 3 the two sweeps are identical.

## Effect of branch prediction
To isolate the predictor, the pipelined CPU was also built with the `RV.v` from just before the predictor was added
(the parent of commit `e6e0283`), so that every taken branch and jump is flushed. All runs PASS.

That `RV.v` also has an older load-use stall check, which treats `jalr` as not using rs1 and `jal` as using it. This
does not affect these results, since the program never has a load directly before a `jalr` or `jal` that uses the
loaded register.

All times are `NS=` from the board.

| Workload | n | No BP CYC | BP CYC | Fewer cycles | No BP time (ns) | BP time (ns) | Speedup from BP |
|---|---|---|---|---|---|---|---|
| `FIBI` | 39 | 1060 | 820 | 22.6% | 21200 | 16400 | 1.29 |
| `FIBR` | 24 | 4726563 | 3861695 | 18.3% | 94531260 | 77233900 | 1.22 |
| `FIBT` | 39 | 1099 | 865 | 21.3% | 21980 | 17300 | 1.27 |
| `PRIM` | 1008 | 512687 | 465991 | 9.1% | 10253740 | 9319820 | 1.10 |

Prediction removes the flush cycles of correctly predicted branches and jumps. One `fib_iter` loop iteration takes 26
cycles without prediction (17 instructions + 3 load-use stalls + 3 taken jumps x 2 flush cycles) and 20 with it. `PRIM`
gains the least because it spends more of its time waiting for MCycle, which prediction does not help.

Even without prediction, the pipelined CPU at 50 MHz is faster than the single-cycle CPU at 25 MHz on every workload
and at every n measured. Flushes take away part of the 2x clock gain, but not all of it:

| Workload | Single-cycle time (ns) | No BP speedup | BP speedup |
|---|---|---|---|
| `FIBI` | 27760 | 1.31 | 1.69 |
| `FIBR` | 132043560 | 1.40 | 1.71 |
| `FIBT` | 27800 | 1.26 | 1.61 |
| `PRIM` | 17576960 | 1.71 | 1.89 |

This only compares the CPUs at these clocks.

### Cost of branch prediction
Both builds have a 50 MHz (20 ns) clock and meet all constraints.

| | No BP | BP |
|---|---|---|
| `clk_out2` WNS | 3.859 ns | 0.700 ns |
| Critical path (period - WNS) | 16.14 ns | 19.30 ns |
| Data path delay | 15.845 ns | 18.721 ns |
| Path start | `rs1_E_reg[3]` | `ReadData_W_reg[4]` |
| Path end | `MCycle1/temp_sum_reg[21]/D` | `Instr_D_reg[15]/R` |
| Clocked elements on `clk_out2` | 3240 | 7095 |
| CPU clock to 100 MHz WNS | 5.533 ns | 5.258 ns |
| 100 MHz to CPU clock WNS | 4.027 ns | 4.607 ns |

With the same constraint, the critical path is 3.16 ns (1.20x) longer with prediction. Without prediction it runs from
an E-stage register into the MCycle adder. With prediction it ends on a flush reset, since the flush now depends on a
32-bit compare of the predicted and actual next PC. The predictor also adds 64 entries of 59 bits each (valid, tag,
2-bit counter and target), which is most of the extra clocked elements.

As before, these critical paths are not f_max. They do suggest the trade-off: prediction reduces the run time by 1.10x
to 1.29x in cycles, at the cost of a path about 1.20x longer. If each build could run at the critical path above, BP
would still win on `FIBI` (about 1.08x), `FIBT` (1.06x) and `FIBR` (1.02x), but lose on `PRIM` (0.92x).
