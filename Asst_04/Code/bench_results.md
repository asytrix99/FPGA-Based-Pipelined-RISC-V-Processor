# Benchmark Results
Results of `bench.c` (see [README](../README.md#benchmark-program)) on the Assignment 3 single-cycle CPU and the
Assignment 4 pipelined CPU.

## Cycle counts
Measured on the board at `CLK_DIV_BITS` = 1 (25 MHz) for both CPUs, same `bench.asm`. All runs PASS.

| Workload | n | Single-cycle CYC | Pipelined CYC | Pipelined / single-cycle |
|---|---|---|---|---|
| `FIBI` | 39 | 694 | 1139 | 1.64 |
| `FIBR` | 24 | 3301089 | 4801589 | 1.45 |
| `FIBT` | 39 | 695 | 1100 | 1.58 |
| `PRIM` | 1008 | 439424 | 512688 | 1.17 |

At the same clock the pipelined CPU needs more cycles, since it loses cycles to hazards and the single-cycle
CPU always takes 1 cycle per instruction. For example, one `fib_iter` loop iteration is 17 instructions: 17 cycles on
the single-cycle CPU, and 28 on the pipelined CPU (3 taken jumps x 2 flush cycles + 5 load-use stalls).
`PRIM` has the smallest ratio because most of its time is spent waiting for MCycle, which takes the same number of
cycles on both CPUs.

## Clock
The gain from pipelining is the shorter critical path. WNS with `CLK_DIV_BITS` = 0 (100 MHz constraint):

| CPU | WNS | Critical path (10 - WNS) | f_max |
|---|---|---|---|
| Single-cycle | -8.156 ns | 18.156 ns | 55.1 MHz |
| Pipelined | -3.573 ns | 13.573 ns | 73.7 MHz |

## Time at f_max
Time at each CPU's own f_max = CYC / f_max:

| Workload | Single-cycle | Pipelined | Speedup |
|---|---|---|---|
| `FIBI` | 12.60 us | 15.46 us | 0.82 |
| `FIBR` | 59.93 ms | 65.17 ms | 0.92 |
| `FIBT` | 12.62 us | 14.93 us | 0.85 |
| `PRIM` | 7.98 ms | 6.96 ms | 1.15 |

f_max only went up by 1.34x, which is less than the extra cycles of `FIBI`, `FIBR` and `FIBT`, so only `PRIM` is
faster. `bench.c` is compiled with `-O0`, where every variable is loaded from and stored to the stack, so there are
many more load-use stalls and taken jumps than in optimised code.
