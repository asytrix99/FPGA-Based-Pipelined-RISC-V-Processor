# CG3207 Assignment 3


## Folder structures
```text
CG3207_Assignment_2/
│
├── Src/
│   ├── AA_DMEM.mem
│   ├── AA_IROM.mem
│   ├── ADXL362Ctrl.vhd
│   ├── ALU.v
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
│   ├── tb_Decoder.v
│   ├── tb_MCycle.v
│   ├── tb_MCycle_self_checking.v
│   ├── tb_PC_Logic.v
│   ├── tb_RV.v
│   ├── test_Wrapper.v
│   ├── test_Wrapper_DIP_to_LED.v
│   └── test_Wrapper_DIP_to_LED_self_checking.v
│
├── Code/
│   ├── accel.c
│   ├── accel.asm
│   ├── parser.cpp
│   ├── make.sh
│   ├── booth_visualizer.html
│   └── prompt.md
│
├── Bitstream/
│   └── Top.bit
│
├── Constraint/
│   ├── Nexys-A7-100T-Master.xdc
│   ├── TOP_Nexys4.xdc
│   └── TOP_Nexys4DDR.xdc
│
├── radix2-booth.pptx
│
└── README.txt
```

## Files changed
### RTL Source Files
- `Decoder.v`
   - Implements the Decoder logic for mul, div and divu.
   - Add additional IsMycle, MCycleOp and MCycleResultHigh as output
- `RV.v`
   - Hook MCycle module and delay PC update when busy
- `MCycle.v`
   - Implement Division logic and Radix 2 booth multiplier for enchancement
- `Wrapper.v`
   - Change DEPTH_BITS to accomodate all required instructions

### Testbench Files
- `tb_Decoder`
    - Implement self-checking simulation for Decoder to check mul and div
- `tb_MCycle_self_checking`
    - Implement self-checking simulation for MCycle. AI has been employed to convert to self checking.
- `tb_RV`
    - Implement self-checking simulation for RV.v.
- `test_Wrapper.v`
    - Update self-checking simulation for accel.c 

### Software
- #### `accel.c`
    C program used for the processor demonstration. Reads and processes acceleromter data and outputs
    the result through UART, LEDs, and seven-segment display. This is an extension from asst2, with included
    mul, div and divu instructions.

- #### `accel.asm` 
    RISC-V assembly generated from `accel.c` using [Godbolt Compiler Explorer](https://godbolt.org/). 
    `RISC-V rv32gc clang 20.1.0` is used to generate the assembly.

 - #### `parser.cpp`
    C++ program used by receiver computer to read data from UART, identify and parse binary packets, and
    display the received data in human readable format. 

    AI has been used to generate the serial-port communication code.

- #### `booth_visualizer.html`
    A HTML visualizer for the Radix 2 booth multiplier. AI has been used to generate this.

- #### `prompt.md`
    A markdown file which include all the AI prompt used for booth_visualizer.html

### Others
- #### `radix2-booth.pptx`
    A powerpoint slides to demonstrate radix 2 booth enchancement

## Demo Program
The demo program reads a 32-bit accelerometer value with the following format:
| Bits  | Value          |
|---    |---             |
| 31:24 | Temperature    |
| 23:16 | X acceleration |
| 15:8  | Y acceleration |
| 7:0   | Z acceleration |

The processed results are output through:
- **UART** – raw and processed accelerometer values
- **LEDs** – comparison/status results
- **Seven-segment display** – raw accelerometer reading

> Some variables in the program are intentionally declared as `volatile` to prevent the compiler
from optimizing operations into immediate instructions. This allows both register and immediate \
variants of the required instructions to be demonstrated.

#### LED Comparison result
| Bits  | Value          |
|---    |---             |
| 0     | magnitude < 20 |
| 1     | magnitude < 60 |
| 2     | x < y          |
| 3     | x < 10         |

> The comparision are included to exercise the different signed/unsigned and register/immediate set-less-than instructions 

