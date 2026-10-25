// Loop-based math benchmark to compare the single-cycle and the pipelined CPU.
// Each workload stresses a different pipeline hazard, and every result is checked by a second method.
// Only int data is used (no char / short), so there are no sb / sh and the program also runs on the Asst_03 CPU.

#define IROM_BASE 0x00400000             // Should be the same as the .txt address based on the Memory Configuration set in the assembler/linker,
                                         // Wrapper.v and the PC default value as well as reset value in **ProgramCounter.v**
#define DMEM_BASE 0x10010000             // Should be the same as the .data address based on the Memory Configuration set in the assembler/linker, and Wrapper.v
#define DMEM_SIZE 0x4000                 // 2**DMEM_DEPTH_BITS, as in Wrapper.v
#define MMIO_BASE 0xFFFF0000             // Should be the same as the .mmio address based on the Memory Configuration set in the assembler/linker, and Wrapper.v
#define STACK_INIT DMEM_BASE + DMEM_SIZE // Top of RAM to allow stack to grow downwards

// Memory-mapped peripheral register offsets
#define UART_RX_VALID_OFF 0x00 // RO, status bit
#define UART_RX_OFF 0x04       // RO
#define UART_TX_READY_OFF 0x08 // RO, status bit
#define UART_TX_OFF 0x0C       // WO
#define LED_OFF 0x60           // WO
#define DIP_OFF 0x64           // RO
#define PB_OFF 0x68            // RO
#define SEVENSEG_OFF 0x80      // WO
#define CYCLECOUNT_OFF 0xA0    // RO

// Keep CLK_DIV_BITS the same as in TOP_Nexys.vhd of the bitstream this program runs on
#ifndef CLK_DIV_BITS
#define CLK_DIV_BITS 1
#endif
// TOP_Nexys.vhd takes the CPU clock from bit CLK_DIV_BITS of a counter, so it divides 100 MHz
// by 2^(CLK_DIV_BITS + 1). CLK_DIV_BITS = 0 bypasses the counter. E.g. 1 -> 25 MHz, 5 -> 1.5625 MHz
#define CLK_SHIFT ((CLK_DIV_BITS == 0) ? 0 : (CLK_DIV_BITS + 1))
#define CLK_HZ (100000000 >> CLK_SHIFT) // CPU clock
#define NS_PER_CYCLE (10 << CLK_SHIFT)  // 10 ns at 100 MHz, doubles for every divide by 2

#ifdef SIM
#define POLL_CYCLES 100 // Small delay for simulation
#else
#define POLL_CYCLES (CLK_HZ / 20) // Check the switches and buttons every ~50 ms
#endif

// Workloads, selected by SW1-SW0
#define WL_FIB_ITER 0  // Iterative Fibonacci: back-to-back dependent adds
#define WL_FIB_REC 1   // Recursive Fibonacci: calls, returns, stack loads and stores
#define WL_FIB_TABLE 2 // Fibonacci table in memory: store then load of the same data
#define WL_PRIMES 3    // Prime count by trial division: remu on MCycle

#define FIB_N_MAX 39     // fib(39) = 63245986 still fits in 8 decimal digits on the 7-seg
#define FIB_REC_N_MAX 24 // Keeps the recursion below ~1 s on a slow clock
#define PRIME_STEP 16    // Prime limit = n * PRIME_STEP, so up to 1008
#define SIEVE_SIZE 1024  // Must be larger than 63 * PRIME_STEP

#define DIP_TIME_BIT (1 << 15)  // SW15: 7-seg shows the time in us instead of the result
#define DIP_SWEEP_BIT (1 << 14) // SW14: run every n of the selected workload, not just the one on SW7-SW2

void uart_send_char(unsigned int c);
void uart_send_dec(unsigned int value);
unsigned int to_bcd(unsigned int value);
void delay(unsigned int cycles);
unsigned int fib_iter(unsigned int n);
unsigned int fib_rec(unsigned int n);
unsigned int fib_table(unsigned int n);
unsigned int count_primes(unsigned int limit);
unsigned int sieve_count(unsigned int limit);
void send_workload_name(unsigned int workload);
volatile unsigned int *CYCLECOUNT_ADDR = (unsigned int *)(MMIO_BASE + CYCLECOUNT_OFF);
volatile unsigned int *UART_TX_ready_ADDR = (unsigned int *)(MMIO_BASE + UART_TX_READY_OFF);
volatile unsigned int *UART_TX_ADDR = (unsigned int *)(MMIO_BASE + UART_TX_OFF);

unsigned int table[FIB_N_MAX + 1]; // Used by fib_table()
unsigned int sieve[SIEVE_SIZE];    // Used by sieve_count(). 1 = not prime

/**
 * @brief Entry point, must be the first function so it is at IROM_BASE. Sets sp before main() builds its
 *        stack frame, otherwise main's locals are stored relative to sp = 0. naked = no stack frame of its own
 */
__attribute__((naked)) void _start(void)
{
    asm volatile("li sp, %0\n\tj main" : : "i"(STACK_INIT));
}

int main()
{
    volatile unsigned int *LED_ADDR = (unsigned int *)(MMIO_BASE + LED_OFF);
    volatile unsigned int *SEVENSEG_ADDR = (unsigned int *)(MMIO_BASE + SEVENSEG_OFF);
    volatile unsigned int *DIP_ADDR = (unsigned int *)(MMIO_BASE + DIP_OFF);
    volatile unsigned int *PB_ADDR = (unsigned int *)(MMIO_BASE + PB_OFF);

    unsigned int prev_dip = 0xFFFFFFFF; // Not a valid switch setting, so the benchmark runs once at start-up
    unsigned int prev_pb = 0;

    while (1)
    {
        unsigned int dip = *DIP_ADDR;
        unsigned int pb = *PB_ADDR;

        // Run when a switch changes, or when any pushbutton goes from released to pressed
        unsigned int pb_pressed = pb & ~prev_pb;
        prev_pb = pb;

        if (dip != prev_dip || pb_pressed)
        {
            prev_dip = dip;

            unsigned int workload = dip & 0x3;
            unsigned int n_first = (dip >> 2) & 0x3F;
            unsigned int n_last = n_first;

            // SW14: sweep every n from 1 to the maximum of this workload, one UART line each
            if (dip & DIP_SWEEP_BIT)
            {
                n_first = 1;
                if (workload == WL_PRIMES)
                    n_last = 0x3F;
                else if (workload == WL_FIB_REC)
                    n_last = FIB_REC_N_MAX;
                else
                    n_last = FIB_N_MAX;
            }

            for (unsigned int n_sw = n_first; n_sw <= n_last; n_sw++)
            {
                unsigned int n = n_sw;
                unsigned int result;
                unsigned int check;
                unsigned int pass;
                unsigned int t_start;
                unsigned int cycles;

                if (workload == WL_PRIMES)
                {
                    n = n * PRIME_STEP;
                }
                else if (workload == WL_FIB_REC)
                {
                    if (n > FIB_REC_N_MAX)
                        n = FIB_REC_N_MAX;
                }
                else
                {
                    if (n > FIB_N_MAX)
                        n = FIB_N_MAX;
                }

                // Timed section: only the selected workload
                t_start = *CYCLECOUNT_ADDR;
                if (workload == WL_FIB_ITER)
                    result = fib_iter(n);
                else if (workload == WL_FIB_REC)
                    result = fib_rec(n);
                else if (workload == WL_FIB_TABLE)
                    result = fib_table(n);
                else
                    result = count_primes(n);
                cycles = *CYCLECOUNT_ADDR - t_start; // Unsigned subtract still works if the counter wraps

                // Check the result with a different method. A pipeline hazard bug makes them disagree
                if (workload == WL_PRIMES)
                {
                    pass = (sieve_count(n) == result);
                }
                else
                {
                    check = fib_iter(n);
                    pass = (fib_table(n) == check) && (result == check);
                    if (n <= FIB_REC_N_MAX)
                        pass = pass && (fib_rec(n) == check);
                }

                unsigned int time_ns = cycles * NS_PER_CYCLE;
                unsigned int time_us = time_ns / 1000;

                // LED0 = pass, LED1 = fail, LED3-2 = workload
                *LED_ADDR = (pass ? 0x1 : 0x2) | (workload << 2);

                // SW15 = 0: result on the 7-seg, SW15 = 1: time in us. Both in decimal
                if (dip & DIP_TIME_BIT)
                    *SEVENSEG_ADDR = to_bcd(time_us);
                else
                    *SEVENSEG_ADDR = to_bcd(result);

                // e.g. FIBI N=39 R=63245986 CYC=1139 NS=45560 PASS
                send_workload_name(workload);
                uart_send_char(' ');
                uart_send_char('N');
                uart_send_char('=');
                uart_send_dec(n);

                uart_send_char(' ');
                uart_send_char('R');
                uart_send_char('=');
                uart_send_dec(result);

                uart_send_char(' ');
                uart_send_char('C');
                uart_send_char('Y');
                uart_send_char('C');
                uart_send_char('=');
                uart_send_dec(cycles);

                uart_send_char(' ');
                uart_send_char('N');
                uart_send_char('S');
                uart_send_char('=');
                uart_send_dec(time_ns);

                uart_send_char(' ');
                if (pass)
                {
                    uart_send_char('P');
                    uart_send_char('A');
                    uart_send_char('S');
                    uart_send_char('S');
                }
                else
                {
                    uart_send_char('F');
                    uart_send_char('A');
                    uart_send_char('I');
                    uart_send_char('L');
                }
                uart_send_char('\r');
                uart_send_char('\n');
            }
        }

        delay(POLL_CYCLES);
    }
    return 0;
}

/**
 * @brief Compute the nth Fibonacci number with a loop
 *
 * Each add needs the result of the previous one, so this stresses forwarding.
 *
 * @param n             Index of the Fibonacci number, fib(0) = 0, fib(1) = 1
 * @return unsigned int fib(n)
 */
unsigned int fib_iter(unsigned int n)
{
    unsigned int a = 0;
    unsigned int b = 1;
    for (unsigned int i = 0; i < n; i++)
    {
        unsigned int next = a + b;
        a = b;
        b = next;
    }
    return a;
}

/**
 * @brief Compute the nth Fibonacci number with naive recursion
 *
 * Makes about 2 * fib(n) calls, so this stresses jal / jalr and the loads and stores of each stack frame.
 *
 * @param n             Index of the Fibonacci number
 * @return unsigned int fib(n)
 */
unsigned int fib_rec(unsigned int n)
{
    if (n < 2)
        return n;
    return fib_rec(n - 1) + fib_rec(n - 2);
}

/**
 * @brief Compute the nth Fibonacci number by filling a table in data memory
 *
 * Each entry is loaded right after the previous one is stored, so this stresses loads, stores and load-use stalls.
 *
 * @param n             Index of the Fibonacci number, at most FIB_N_MAX
 * @return unsigned int fib(n)
 */
unsigned int fib_table(unsigned int n)
{
    // Through a pointer, so the compiler emits sw a0, 4(a1) instead of sw a0, %lo(table+4)(a1),
    // which RARS cannot assemble
    unsigned int *t = table;

    t[0] = 0;
    t[1] = 1;
    for (unsigned int i = 2; i <= n; i++)
        t[i] = t[i - 1] + t[i - 2];
    return t[n];
}

/**
 * @brief Count the primes up to a limit by trial division
 *
 * Uses mul for d * d and remu for k % d, so this stresses MCycle and the forwarding of its result into a branch.
 *
 * @param limit         The largest number to check
 * @return unsigned int The number of primes from 2 to limit
 */
unsigned int count_primes(unsigned int limit)
{
    unsigned int count = 0;
    for (unsigned int k = 2; k <= limit; k++)
    {
        unsigned int is_prime = 1;
        for (unsigned int d = 2; d * d <= k; d++)
        {
            if (k % d == 0)
            {
                is_prime = 0;
                break;
            }
        }
        count = count + is_prime;
    }
    return count;
}

/**
 * @brief Count the primes up to a limit with the sieve of Eratosthenes
 *
 * Used to check count_primes() with a different method.
 *
 * @param limit         The largest number to check, less than SIEVE_SIZE
 * @return unsigned int The number of primes from 2 to limit
 */
unsigned int sieve_count(unsigned int limit)
{
    for (unsigned int i = 0; i <= limit; i++)
        sieve[i] = 0;

    for (unsigned int i = 2; i * i <= limit; i++)
    {
        if (!sieve[i])
        {
            for (unsigned int j = i * i; j <= limit; j += i)
                sieve[j] = 1;
        }
    }

    unsigned int count = 0;
    for (unsigned int k = 2; k <= limit; k++)
    {
        if (!sieve[k])
            count = count + 1;
    }
    return count;
}

/**
 * @brief Transmit the 4-letter name of a workload over UART
 *
 * Uses if / else instead of a switch, so the compiler does not need a jump table in data memory.
 *
 * @param workload The workload number, 0 to 3
 */
void send_workload_name(unsigned int workload)
{
    if (workload == WL_FIB_ITER)
    {
        uart_send_char('F');
        uart_send_char('I');
        uart_send_char('B');
        uart_send_char('I');
    }
    else if (workload == WL_FIB_REC)
    {
        uart_send_char('F');
        uart_send_char('I');
        uart_send_char('B');
        uart_send_char('R');
    }
    else if (workload == WL_FIB_TABLE)
    {
        uart_send_char('F');
        uart_send_char('I');
        uart_send_char('B');
        uart_send_char('T');
    }
    else
    {
        uart_send_char('P');
        uart_send_char('R');
        uart_send_char('I');
        uart_send_char('M');
    }
}

/**
 * @brief Blocks execution for a specified number of hardware clock cycles
 *
 * @param cycles The number of clock cycles to delay
 */
void delay(unsigned int cycles)
{
    unsigned int starting_count = *CYCLECOUNT_ADDR;
    while ((*CYCLECOUNT_ADDR - starting_count) < cycles)
        ; // Unsigned subtract still works if the counter wraps
}

/**
 * @brief Transmit a single character over UART
 *
 * This function blocks until UART transmit is ready, and write the char to the transmit rigister
 *
 * @param c The character to be transmitted.
 */
void uart_send_char(unsigned int c)
{
    while (!(*UART_TX_ready_ADDR))
        ;
    *UART_TX_ADDR = c;
}

/**
 * @brief Transmit a value over UART in decimal
 *
 * The digits are stored in an int array, so no sb / lbu is needed.
 *
 * @param value The value to be transmitted
 */
void uart_send_dec(unsigned int value)
{
    unsigned int digits[10]; // 2^32 - 1 has 10 decimal digits
    unsigned int count = 0;

    do
    {
        digits[count] = value % 10;
        value = value / 10;
        count = count + 1;
    } while (value != 0);

    while (count > 0)
    {
        count = count - 1;
        uart_send_char('0' + digits[count]);
    }
}

/**
 * @brief Convert a value to BCD, so that it shows in decimal on the 7-seg
 *
 * @param value The value to be converted. Only the lowest 8 decimal digits are kept
 * @return unsigned int The BCD value, one decimal digit per 4 bits
 */
unsigned int to_bcd(unsigned int value)
{
    unsigned int bcd = 0;
    for (unsigned int shift = 0; shift < 32; shift += 4)
    {
        bcd |= (value % 10) << shift;
        value = value / 10;
    }
    return bcd;
}