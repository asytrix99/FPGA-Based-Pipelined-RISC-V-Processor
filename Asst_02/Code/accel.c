#define IROM_BASE 0x00400000		// Should be the same as the .txt address based on the Memory Configuration set in the assembler/linker, 
                                    // Wrapper.v and the PC default value as well as reset value in **ProgramCounter.v** 
#define DMEM_BASE 0x10010000   	// Should be the same as the .data address based on the Memory Configuration set in the assembler/linker, and Wrapper.v
#define DMEM_SIZE 0x200         // 2**DMEM_DEPTH_BITS, as in Wrapper.v
#define MMIO_BASE 0xFFFF0000   // Should be the same as the .mmio address based on the Memory Configuration set in the assembler/linker, and Wrapper.v
#define STACK_INIT DMEM_BASE + DMEM_SIZE // Top of RAM to allow stack to grow downwards

// Memory-mapped peripheral register offsets
#define UART_RX_VALID_OFF	0x00 //RO, status bit
#define UART_RX_OFF 		0x04 //RO
#define UART_TX_READY_OFF	0x08 //RO, status bit
#define UART_TX_OFF 		0x0C //WO
#define OLED_COL_OFF 		0x20 //WO
#define OLED_ROW_OFF 		0x24 //WO
#define OLED_DATA_OFF 		0x28 //WO
#define OLED_CTRL_OFF 		0x2C //WO 
#define ACCEL_DATA_OFF 		0x40 //RO
#define ACCEL_DREADY_OFF 	0x44 //RO, status bit
#define LED_OFF 			0x60 //WO
#define DIP_OFF 			0x64 //RO
#define PB_OFF  			0x68 //RO
#define SEVENSEG_OFF 		0x80 //WO
#define CYCLECOUNT_OFF 		0xA0 //RO
                                 // Not using ACCEL_DREADY_OFF as we poll at a low freq, should be ready

void uart_send_char(unsigned int c);
void uart_send_hex_word(unsigned int value);
void uart_send_hex_byte(unsigned int value);
void delay(unsigned int cycles);
volatile unsigned int* CYCLECOUNT_ADDR = (unsigned int*) (MMIO_BASE+CYCLECOUNT_OFF); 
volatile unsigned int* UART_TX_ready_ADDR = (unsigned int*) (MMIO_BASE+UART_TX_READY_OFF);
volatile unsigned int* UART_TX_ADDR = (unsigned int*) (MMIO_BASE+UART_TX_OFF);
// making CYCLECOUNT_ADDR global just to use data memory :)

int main()
{
    asm volatile("li sp, %0" : : "i" (STACK_INIT)); //inline assembly to init sp. Registers cant be accessed explicitly in pure C
    volatile unsigned int* ACCEL_Data_ADDR = (unsigned int*) (MMIO_BASE+ACCEL_DATA_OFF); // temp, x, y, z

    volatile unsigned int* SEVENSEG_ADDR = (unsigned int*) (MMIO_BASE+SEVENSEG_OFF);

    while(1)
    {
        unsigned int accel_reading = *ACCEL_Data_ADDR;
        unsigned int accel_reading_mag = 0;

        // display the magnitude on seven segment display
        *SEVENSEG_ADDR = accel_reading;

        uart_send_char('T');
        uart_send_char('=');

        // Temp byte
        unsigned int temp = (accel_reading >> 24) & 0xFF;
        uart_send_hex_byte(temp);

        uart_send_char(' ');
        uart_send_char('X');
        uart_send_char('=');

        unsigned int x_byte = (accel_reading >> 16) & 0xFF;
        uart_send_hex_byte(x_byte);

        uart_send_char(' ');
        uart_send_char('Y');
        uart_send_char('=');

        unsigned int y_byte = (accel_reading >> 8) & 0xFF;
        uart_send_hex_byte(y_byte);

        uart_send_char(' ');
        uart_send_char('Z');
        uart_send_char('=');

        unsigned int z_byte = accel_reading & 0xFF;
        uart_send_hex_byte(z_byte);


        // Sign extend
        int x_signed = (x_byte & 0x80)
            ? (int)(x_byte | 0xFFFFFF00)
            : (int)x_byte;

        int y_signed = (y_byte & 0x80)
            ? (int)(y_byte | 0xFFFFFF00)
            : (int)y_byte;

        int z_signed = (z_byte & 0x80)
            ? (int)(z_byte | 0xFFFFFF00)
            : (int)z_byte;
        unsigned int x_mag = (x_signed < 0) ? -x_signed : x_signed;
        unsigned int y_mag = (y_signed < 0) ? -y_signed : y_signed;
        unsigned int z_mag = (z_signed < 0) ? -z_signed : z_signed;

        accel_reading_mag = x_mag + y_mag + z_mag;

        uart_send_char(' ');
        uart_send_char('M');
        uart_send_char('=');
        uart_send_hex_word(accel_reading_mag);
        uart_send_char('\r');
        uart_send_char('\n');

        // 1000000 for ~1/3 sec at CLK_DIV_BITS = 5.
        delay(1000000); // change to a much smaller value for simulation
    }
    return 0;
}

void delay(unsigned int cycles)
{
    unsigned int starting_count = *CYCLECOUNT_ADDR;
    while(*CYCLECOUNT_ADDR < starting_count + cycles);
}

void uart_send_char(unsigned int c)
{
    while (!(*UART_TX_ready_ADDR));
    *UART_TX_ADDR = c;
}

void uart_send_hex_digit(unsigned int digit)
{
    if (digit < 10)
        uart_send_char('0' + digit);
    else
        uart_send_char('A' + digit - 10);
}

void uart_send_hex_byte(unsigned int value)
{
    uart_send_hex_digit((value >> 4) & 0xF);
    uart_send_hex_digit(value & 0xF);
}

void uart_send_hex_word(unsigned int value)
{
    uart_send_hex_digit((value >> 12) & 0xF);
    uart_send_hex_digit((value >> 8) & 0xF);
    uart_send_hex_digit((value >> 4) & 0xF);
    uart_send_hex_digit(value & 0xF);
}
