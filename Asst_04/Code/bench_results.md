# Benchmark Results
Results of `bench.c` (see [README](../README.md#benchmark-program)) on two CPUs:

- **Single-cycle:** the Assignment 3 CPU at 40 MHz
- **Pipelined + BP:** the Assignment 4 pipelined CPU with branch prediction at 50 MHz

Each CPU is clocked by the Clocking Wizard (`clk_out2`):

| CPU | Clock | `-DCLK_PERIOD_PS` |
|---|---|---|
| Single-cycle | 40 MHz | 25000 |
| Pipelined + BP | 50 MHz | 20000 |

The [effect of branch prediction](#effect-of-branch-prediction) section also uses the same pipelined CPU with the
predictor turned off, at 50 MHz.

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
From the timing reports of the builds that ran on the board:
[single-cycle](../Timing%20Reports/TOP_timing_summary_routed_non-pipelined.rpt) and
[pipelined + BP](../Timing%20Reports/TOP_timing_summary_routed_pipelined_prediction.rpt). Both meet all constraints.

| | Single-cycle | Pipelined + BP |
|---|---|---|
| Clock period | 25 ns | 20 ns |
| `clk_out2` WNS | 1.090 ns | 0.870 ns |
| Critical path (period - WNS) | 23.91 ns | 19.13 ns |
| Data path delay | 23.362 ns | 18.200 ns |
| Path start | `PC_reg[8]_rep__1` | `ReadData_W_reg[15]` |
| Path end | `RegBank_reg_r1_0_31_0_5/RAMB/I` | `RD1_E_reg[15]/R` |

The single-cycle critical path runs from the PC to a register file write, while the pipelined critical path runs from
a W-stage register to the reset of an E-stage register.

These critical paths cannot be used as f_max, because the tool stops optimising once a constraint is met.

The slack on the paths between the CPU clock and the 100 MHz peripheral clock is also positive:

| Path | Single-cycle WNS | Pipelined + BP WNS |
|---|---|---|
| CPU clock to 100 MHz | 0.643 ns | 5.253 ns |
| 100 MHz to CPU clock | 0.037 ns | 4.783 ns |

## Time on the board
All times are `NS=` from the board.

| Workload | n | Single-cycle time (ns) | Pipelined + BP time (ns) | Speedup |
|---|---|---|---|---|
| `FIBI` | 39 | 17350 | 16400 | 1.06 |
| `FIBR` | 24 | 82527225 | 77233900 | 1.07 |
| `FIBT` | 39 | 17375 | 17300 | 1.00 |
| `PRIM` | 1008 | 10985600 | 9319820 | 1.18 |

Run time is the number of cycles x the clock period, so the speedup depends on both:

```text
Speedup = single-cycle time / pipelined time
        = (single-cycle CYC x 25 ns) / (pipelined CYC x 20 ns)
        = 1.25 / (pipelined CYC / single-cycle CYC)
```

Pipelining splits each instruction across 5 stages, which is what allows the 1.25x faster clock here, but hazards add
cycles. The pipelined CPU is only faster overall when it needs less than 1.25x the cycles:

| Workload | Clock gain | Cycle ratio | Speedup | Reason |
|---|---|---|---|---|
| `FIBI` | 1.25 | 1.18 | 1.06 | The loop's jumps are easy to predict, so the main cost is load-use stalls from using values right after loading them from the stack |
| `FIBR` | 1.25 | 1.17 | 1.07 | Recursion is harder to predict, since the same `ret` goes back to different places and the base case check changes between calls. Stack loads also cause stalls |
| `FIBT` | 1.25 | 1.24 | 1.00 | Each entry is loaded from the table and used straight away, which adds another load-use stall to the loop, so almost all of the clock gain is lost |
| `PRIM` | 1.25 | 1.06 | 1.18 | `mul` and `remu` wait for MCycle on both CPUs, so hazards are a small part of the run time, and those waits finish sooner on the faster clock |

The result also depends on n:

| Workload | Pipelined + BP is faster from |
|---|---|
| `FIBI` | n = 2 (ties at n = 1) |
| `FIBR` | n = 4 |
| `FIBT` | n = 25 (ties at n = 24) |
| `PRIM` | Every n measured (16 to 1008) |

## Effect of branch prediction
To isolate the predictor, the same CPU was run with it turned off (`PrTakenF` = 0 in `Branch_Prediction.v`), so that
every taken branch and jump is flushed. Everything else is the same, including the load-use stall check. All runs PASS.

Both times are for the 50 MHz clock, calculated as `CYC=` x 20 ns. The `NS=` values of the run without prediction are
not used, since that program was compiled with `-DCLK_PERIOD_PS=15000`. This does not affect `CYC=`.

| Workload | n | No BP CYC | BP CYC | Fewer cycles | No BP time (ns) | BP time (ns) | Speedup from BP |
|---|---|---|---|---|---|---|---|
| `FIBI` | 39 | 1060 | 820 | 22.6% | 21200 | 16400 | 1.29 |
| `FIBR` | 24 | 4726563 | 3861695 | 18.3% | 94531260 | 77233900 | 1.22 |
| `FIBT` | 39 | 1099 | 865 | 21.3% | 21980 | 17300 | 1.27 |
| `PRIM` | 1008 | 512687 | 465991 | 9.1% | 10253740 | 9319820 | 1.10 |

Prediction removes the flush cycles of correctly predicted branches and jumps. One `fib_iter` loop iteration takes 26
cycles without prediction (17 instructions + 3 load-use stalls + 3 taken jumps x 2 flush cycles) and 20 with it. `PRIM`
gains the least because it spends more of its time waiting for MCycle, which prediction does not help.

Without prediction, the pipelined CPU at 50 MHz is slower than the single-cycle CPU at 40 MHz on the Fibonacci
workloads, because flushes take away more than the 1.25x clock gain:

| Workload | Single-cycle time (ns) | No BP speedup | BP speedup |
|---|---|---|---|
| `FIBI` | 17350 | 0.82 | 1.06 |
| `FIBR` | 82527225 | 0.87 | 1.07 |
| `FIBT` | 17375 | 0.79 | 1.00 |
| `PRIM` | 10985600 | 1.07 | 1.18 |

This only compares the CPUs at these clocks.

### Cost of branch prediction
Both builds have a 50 MHz (20 ns) clock and meet all constraints:
[no BP](../Timing%20Reports/TOP_timing_summary_routed_pipelined_no_prediction.rpt) and
[BP](../Timing%20Reports/TOP_timing_summary_routed_pipelined_prediction.rpt).

| | No BP | BP |
|---|---|---|
| `clk_out2` WNS | 3.994 ns | 0.870 ns |
| Critical path (period - WNS) | 16.01 ns | 19.13 ns |
| Data path delay | 15.531 ns | 18.200 ns |
| Path start | `rd_W_reg[3]` | `ReadData_W_reg[15]` |
| Path end | `Instr_D_reg[19]/R` | `RD1_E_reg[15]/R` |
| Clocked elements on `clk_out2` | 3185 | 7102 |
| CPU clock to 100 MHz WNS | 5.031 ns | 5.253 ns |
| 100 MHz to CPU clock WNS | 4.642 ns | 4.783 ns |

With the same constraint, the critical path is 3.12 ns (1.20x) longer with prediction. Both critical paths end on a
flush reset, and the flush now depends on a 32-bit compare of the predicted and actual next PC. The predictor also
adds 64 entries of 59 bits each (valid, tag, 2-bit counter and target), which is most of the extra clocked elements.

As before, these critical paths are not f_max. They do suggest the trade-off: prediction reduces the run time by 1.10x
to 1.29x in cycles, at the cost of a path about 1.20x longer. If each build could run at the critical path above, BP
would still win on `FIBI` (about 1.08x), `FIBT` (1.06x) and `FIBR` (1.02x), but lose on `PRIM` (0.92x).
