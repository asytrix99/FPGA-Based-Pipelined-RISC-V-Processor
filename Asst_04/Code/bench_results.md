# Benchmark Results
Results of `bench.c` (see [README](../README.md#benchmark-program)) on two CPUs:

- **Single-cycle:** the last single-cycle `RV.v`, Assignment 3 CPU
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
per instruction (non Mcycle). For example, one `fib_iter` loop iteration is 17 instructions: 17 cycles on the single-cycle CPU, and
20 on the pipelined CPU (3 load-use stalls). The loop's taken jumps cost no flush cycles once they are predicted
correctly.

`PRIM` has the smallest ratio because most of its time is spent waiting for MCycle, which takes the same number of
cycles on both CPUs. `bench.c` is compiled with `-O0`, where every variable is loaded from and stored to the stack, so
there are many more load-use stalls and taken jumps than in optimised code.


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

The 2x clock gain comes from the clocks chosen here, not from a measured f_max for each CPU.

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
To isolate the effect of branch prediction, the pipelined CPU was also tested at 50 MHz with `PrTakenF` forced to   `1'b0`, making Fetch always select `PC + 4`. Recovery redirects the PC and flushes instructions only when the actual next PC differs from `PC + 4`. All runs PASS.

All times are `NS=` from the board.

| Workload | n | No BP CYC | BP CYC | Fewer cycles | No BP time (ns) | BP time (ns) | Speedup from BP |
|---|---|---|---|---|---|---|---|
| `FIBI` | 39 | 900 | 820 | 8.9% | 18000 | 16400 | 1.10 |
| `FIBR` | 24 | 4426461 | 3861695 | 12.8% | 88529220 | 77233900 | 1.15 |
| `FIBT` | 39 | 939 | 865 | 7.9% | 18780 | 17300 | 1.09 |
| `PRIM` | 1008 | 485301 | 465991 | 4.0% | 9706020 | 9319820 | 1.04 |

Prediction removes the flush cycles of correctly predicted branches and jumps. One `fib_iter` loop iteration takes 22
cycles without prediction (17 instructions + 3 load-use stalls + 1 taken jumps x 2 flush cycles) and 20 with it. `PRIM`
gains the least because it spends more of its time waiting for MCycle, which prediction does not help.

Even without prediction, the pipelined CPU at 50 MHz is faster than the single-cycle CPU at 25 MHz on every workload
and at every n measured. Flushes take away part of the 2x clock gain, but not all of it:

| Workload | Single-cycle time (ns) | No BP speedup | BP speedup |
|---|---|---|---|
| `FIBI` | 27760 | 1.54 | 1.69 |
| `FIBR` | 132043560 | 1.49 | 1.71 |
| `FIBT` | 27800 | 1.48 | 1.61 |
| `PRIM` | 17576960 | 1.81 | 1.89 |

This only compares the CPUs at these clocks.

