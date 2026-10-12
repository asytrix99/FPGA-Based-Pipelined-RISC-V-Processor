// This code is made to be inefficient to force the compiler to use certain RISC-V instructions


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
void uart_send_byte(unsigned int value);
void uart_send_hex_halfword(unsigned int value);
void uart_send_hex_byte(unsigned int value);
void uart_send_u32(unsigned int value);
void delay(unsigned int cycles);
volatile unsigned int* CYCLECOUNT_ADDR = (unsigned int*) (MMIO_BASE+CYCLECOUNT_OFF); 
volatile unsigned int* UART_TX_ready_ADDR = (unsigned int*) (MMIO_BASE+UART_TX_READY_OFF);
volatile unsigned int* UART_TX_ADDR = (unsigned int*) (MMIO_BASE+UART_TX_OFF);

// making CYCLECOUNT_ADDR global just to use data memory :)

#define MAGIC 0x67

typedef struct {
    unsigned int magic;
    unsigned int check_sum;
    unsigned int raw_data;
    int x_scaled;
    int y_scaled;
    int z_scaled;
} TPacket;

void uart_send_packet(TPacket tpacket);

TPacket make_packet(unsigned int accel_reading, int x_scaled, int y_scaled, int z_scaled);

int main()
{
    asm volatile("li sp, %0" : : "i" (STACK_INIT)); //inline assembly to init sp. Registers cant be accessed explicitly in pure C
    volatile unsigned int* ACCEL_Data_ADDR = (unsigned int*) (MMIO_BASE+ACCEL_DATA_OFF); // temp, x, y, z

    volatile unsigned int* LED_ADDR = (unsigned int*) (MMIO_BASE+LED_OFF);
    volatile unsigned int* SEVENSEG_ADDR = (unsigned int*) (MMIO_BASE+SEVENSEG_OFF);

    while(1)
    {
        unsigned int accel_reading = *ACCEL_Data_ADDR;
        unsigned int accel_reading_mag = 0;

        // display the reading on seven segment display
        *SEVENSEG_ADDR = accel_reading;

        uart_send_char('T');
        uart_send_char('=');

        // Use volatile to make it into a rigister shift
        volatile unsigned int mask = 255;
        volatile unsigned int shift = 24;


        // Temp byte
        unsigned int temp = (accel_reading >> shift) & mask;
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

        // Use volatile to make it reigster
        volatile unsigned int sign_extend_mask = 0xFFFFFF00;

        // Sign extend
        int x_signed = (x_byte & 0x80)
            ? (int)(x_byte | sign_extend_mask)
            : (int)x_byte;

        int y_signed = (y_byte & 0x80)
            ? (int)(y_byte | 0xFFFFFF00)
            : (int)y_byte;

        int z_signed = (z_byte & 0x80)
            ? (int)(z_byte | 0xFFFFFF00)
            : (int)z_byte;

        volatile int scale = 1;
        int x_scaled = x_signed >> 1;
        int y_scaled = y_signed >> 1;
        int z_scaled = z_signed >> scale;


        unsigned int x_mag = (x_signed < 0) ? -x_signed : x_signed;
        unsigned int y_mag = (y_signed < 0) ? -y_signed : y_signed;
        unsigned int z_mag = (z_signed < 0) ? -z_signed : z_signed;

        accel_reading_mag = x_mag + y_mag + z_mag;

        uart_send_char(' ');
        uart_send_char('M');
        uart_send_char('=');
        uart_send_hex_halfword(accel_reading_mag);

        // Test for more branch
        unsigned int max_axis = x_mag;
        unsigned int axis = 'X';

        if (y_mag > max_axis) {
            max_axis = y_mag;
            axis = 'Y';
        }

        if (z_mag > max_axis) {
            max_axis = z_mag;
            axis = 'Z';
        }

        uart_send_char(' ');
        uart_send_char('A');
        uart_send_char('=');
        uart_send_char(axis);

        uart_send_char(' ');
        uart_send_char('S');
        uart_send_char('=');

        int mag = 60;
        int is_mag_small = accel_reading_mag < 20;
        int is_mag_med = accel_reading_mag < mag;
        int is_x_less_y = x_signed < y_signed;
        int is_x_small = x_signed < 10;

        *LED_ADDR = is_mag_small | (is_mag_med << 1) | (is_x_less_y << 2) | (is_x_small << 3);

        if (accel_reading_mag < 20) {
            uart_send_char('L');
        }
        else if (is_mag_med) {
            uart_send_char('M');
        }
        else {
            uart_send_char('H');
        }

        // Test for mul and div
        // int magnitude_square = x_signed * x_signed + y_signed * y_signed + z_signed * z_signed;
      long long magnitude_square =
            (long long)x_signed * x_signed +
            (long long)y_signed * y_signed +
            (long long)z_signed * z_signed;

        volatile int num = 3;
        int mean_square = (int) magnitude_square / num;

        volatile unsigned int num_axes = 3;
        unsigned int average_absolute = accel_reading_mag / num_axes;


        uart_send_char(' ');
        uart_send_char('M');
        uart_send_char('A');
        uart_send_char('G');
        uart_send_char('=');
        uart_send_hex_halfword((unsigned int)mean_square);
        
        uart_send_char(' ');
        uart_send_char('A');
        uart_send_char('V');
        uart_send_char('G');
        uart_send_char('=');
        uart_send_hex_halfword(average_absolute);
        
        TPacket tpacket = make_packet(accel_reading, x_scaled, y_scaled, z_scaled);
        uart_send_packet(tpacket);


        uart_send_char('\r');
        uart_send_char('\n');

        // 1000000 for ~1/3 sec at CLK_DIV_BITS = 5.
        delay(1000000); // change to a much smaller value for simulation
    }
    return 0;
}

/**
 * @brief Blocks execution for a specified number of hardware clock cycles
 *
 * @param cycles The number of clock cycles to delay
 */
void delay(unsigned int cycles)
{
    unsigned int starting_count = *CYCLECOUNT_ADDR;
    while(*CYCLECOUNT_ADDR < starting_count + cycles);
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
    while (!(*UART_TX_ready_ADDR));
    *UART_TX_ADDR = c;
}


/**
 * @brief Transmit a single byte over UART
 *
 * This function clears all other bits other than the first 8 bits before writing to the transmit register.
 *
 * @param value The byte to be transmitted
 */ 
void uart_send_byte(unsigned int value) {
    volatile unsigned int mask = 0xFF;
    unsigned int tx_value = value & mask;

    while (!(*UART_TX_ready_ADDR));
    *UART_TX_ADDR = tx_value;
}

/**
 * @brief Transmit a hex value character over UART
 *
 * @param digit The desire digit to be converted to hex and send as a char
 */ 
void uart_send_hex_digit(unsigned int digit)
{
    if (digit < 10)
        uart_send_char('0' + digit);
    else
        uart_send_char('A' + digit - 10);
}

/**
 * @brief Transmit a byte value over UART in hex representation
 *
 * This function breaks the byte into 2 4-bit value and send the required hex represntation through
 * the function uart_send_hex_digit
 *
 * @param value The desire byte to be converted to hex and send over UART
 */ 
void uart_send_hex_byte(unsigned int value)
{
    uart_send_hex_digit((value >> 4) & 0xF);
    uart_send_hex_digit(value & 0xF);
}

/**
 * @brief Transmit a halfword value over UART in hex representation
 *
 * This function breaks the byte into 4 4-bit value and send the required hex represntation through
 * the function uart_send_hex_digit
 *
 * @param value The desire halfword to be converted to hex and send over UART
 */ 
void uart_send_hex_halfword(unsigned int value)
{
    uart_send_hex_digit((value >> 12) & 0xF);
    uart_send_hex_digit((value >> 8) & 0xF);
    uart_send_hex_digit((value >> 4) & 0xF);
    uart_send_hex_digit(value & 0xF);
}


/**
 * @brief Transmit a word value over UART in raw format
 *
 * This function break the word into 4 bytes and send the bytes over UART 
 *
 * @param value The desire word to be send over UART
 */ 
void uart_send_u32(unsigned int value) {
    volatile unsigned int shift24 = 24;
    volatile unsigned int shift16 = 16;
    volatile unsigned int shift8  = 8;
    volatile unsigned int mask = 0xFF;

    uart_send_byte((value >> shift24) & mask);
    uart_send_byte((value >> shift16) & mask);
    uart_send_byte((value >> shift8)  & mask);
    uart_send_byte(value & mask);
}


/**
 * @brief Transmit a packet over UART
 *
 * This function unpacks the TPacket and send the TPacket byte by byte over UART 
 *
 * @param tpacket The desire packet to be send over UART
 */ 
void uart_send_packet(TPacket tpacket) {
    uart_send_byte(tpacket.magic);
    uart_send_byte(tpacket.check_sum);

    uart_send_byte(0);
    uart_send_byte(0);

    uart_send_u32(tpacket.raw_data);
    uart_send_u32((unsigned int)tpacket.x_scaled);
    uart_send_u32((unsigned int)tpacket.y_scaled);
    uart_send_u32((unsigned int)tpacket.z_scaled);
}

/**
 * @brief Take raw accelerometer data and scaled reading into a TPacket
 * 
 * The function take in the 32-bit raw accel_reading, computes the checksum.
 * It then pack all the required values into a TPacket format
 *
 * @param accel_reading The raw 32-bit accelerometer reading
 * @param x_scaled      The scaled x reading 
 * @param y_scaled      The scaled y reading
 * @param z_scaled      The scaled z reading
 * @return TPacket      The fully populated packet for transmittion
 */ 
TPacket make_packet(unsigned int accel_reading, int x_scaled, int y_scaled, int z_scaled) {
    TPacket tpacket = {0};
    tpacket.magic = MAGIC;

    // Use volatile to force 
    volatile int val = 24;

    tpacket.check_sum =
        MAGIC ^
        ((accel_reading >> val) & 0xFF) ^
        ((accel_reading >> 16) & 0xFF) ^
        ((accel_reading >> 8) & 0xFF) ^
        (accel_reading & 0xFF);
    tpacket.raw_data = accel_reading;
    tpacket.x_scaled = x_scaled;
    tpacket.y_scaled = y_scaled;
    tpacket.z_scaled = z_scaled;

    return tpacket;
}

