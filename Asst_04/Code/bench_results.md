# Benchmark Results
Results of `bench.c` (see [README](../README.md#benchmark-program)) on the Assignment 3 single-cycle CPU and the
Assignment 4 pipelined CPU.

## Cycle counts
Measured on the board, same `bench.c` for both CPUs. The cycle count does not depend on the clock. All runs PASS.

| Workload | n | Single-cycle CYC | Pipelined CYC | Pipelined / single-cycle |
|---|---|---|---|---|
| `FIBI` | 39 | 694 | 1139 | 1.64 |
| `FIBR` | 24 | 3301089 | 4801589 | 1.45 |
| `FIBT` | 39 | 695 | 1100 | 1.58 |
| `PRIM` | 1008 | 439424 | 512688 | 1.17 |

The pipelined CPU needs more cycles, since it loses cycles to hazards and the single-cycle CPU always takes 1 cycle
per instruction. For example, one `fib_iter` loop iteration is 17 instructions: 17 cycles on the single-cycle CPU, and
28 on the pipelined CPU (3 taken jumps x 2 flush cycles + 5 load-use stalls). `PRIM` has the smallest ratio because
most of its time is spent waiting for MCycle, which takes the same number of cycles on both CPUs. `bench.c` is
compiled with `-O0`, where every variable is loaded from and stored to the stack, so there are many more load-use
stalls and taken jumps than in optimised code.

## Clock
The gain from pipelining is the shorter critical path. WNS after implementation with `CLK_DIV_BITS` = 0
(100 MHz constraint):

| CPU | WNS | Critical path (10 - WNS) | f_max |
|---|---|---|---|
| Single-cycle | -10.627 ns | 20.627 ns | 48.5 MHz |
| Pipelined | -3.708 ns | 13.708 ns | 73.0 MHz |

f_max is 1.50x higher on the pipelined CPU. Its critical path is still long because `FlushE` resets all ~160 E-stage
registers, and the path from the W stage through forwarding, the ALU and the branch decision ends on those resets.

## Time on the board
Each CPU is clocked by the Clocking Wizard (`clk_out2`) instead of the divider, at the fastest clock below its f_max
that divides evenly into the 100 MHz peripheral clock, so that the CPU to UART / 7-seg paths also meet timing.
All setup and hold slacks are positive.

| CPU | Clock | `-DCLK_PERIOD_PS` |
|---|---|---|
| Single-cycle | 40 MHz | 25000 |
| Pipelined | 66.667 MHz | 15000 |

| Workload | Single-cycle time (ns) | Pipelined time (ns) | Speedup |
|---|---|---|---|
| `FIBI` | 17350 | 17085 | 1.02 |
| `FIBR` | 82527225 | 72023835 | 1.15 |
| `FIBT` | 17375 | 16500 | 1.05 |
| `PRIM` | 10985600 | 7690320 | 1.43 |

The pipelined times are `NS=` from the board. The single-cycle times are the measured `CYC=` x 25 ns.

The pipelined CPU runs at 96% of its f_max but the single-cycle CPU only at 82%, because 45-48 MHz does not divide
evenly into 100 MHz. This favours the pipelined CPU, so the speedup is smaller when both run at their exact f_max.
