# Prompts for the task 4 visualisation

### V1

Create an interactive visualisation for our radix-2 Booth multiplier in MCycle.v, which is our enhancement for task 3. the visualisation should follow our actual Verilog implementation rather than just using a generic Booth multiplication algorithm

The tool should be a single HTML file with CSS and JavaScript included. users should be able to enter signed operands and go through the multiplication cycle by cycle

show the important registers like booth_p, booth_a, booth_sum, booth_tmp and temp_sum. Also show the accumulator, multiplier and Q-1 separately, including how the last 2 bits of booth_p determine whether to add, subtract or do nothing

For each cycle, show the calculation being performed, the right shift and how the register values change. it should also show the cycle count and final multiplication result

the visualisation should be interactive and mainly visual, since we will be using it to explain the algorithm during our oral examination

### V2

Improve the overall layout so it looks more suitable for a formal engineering examination. the current version has too much text and feels more like a tutorial rather than a demonstration tool

Use a cleaner design with consistent colours and font sizes. reduce the amount of explanation and focus more on showing the actual calculations and register changes, since we will explain the details ourselves during the presentation

remove any personal names or references to our previous conversations. The interface should only contain information relevant to the hardware and algorithm, without unnecessary introductory sections

Keep the operand inputs, cycle controls and register displays easy to access. also try to fit the important information within the screen so we don't need to scroll too much during the demonstration

### V3

For this version, focus specifically on the radix-2 Booth multiplier. remove temp_sum from the visualisation since it only copies the product bits from booth_p and isn't directly involved in the Booth calculation

Also remove the comparison with the original sequential multiplier on the right side. instead, use that space for a clear datapath diagram showing how the Booth calculation works

the diagram should show how booth_p[1:0] selects the operation, followed by the addition or subtraction, how booth_sum and booth_tmp are formed, and finally how the next booth_p is obtained after shifting

Try to make the datapath mostly visual rather than using long text explanations. it should be easy for us to point at the different parts and explain the computation during the oral examination

also ensure that all the binary values use consistent font sizes and alignment, especially booth_tmp and next booth_p. the values in both columns should be equally readable

### V4

Update the operand width input to support any integer from 2 to 32 bits, including values like 7 or 13. the register sizes, signed operand limits and iteration count should change automatically based on the selected width

For larger widths, especially 32 bits, the binary values are difficult to read and some overflow their sections. Could you group the binary digits in sets of 4, and add horizontal scrolling for the longer registers? this should apply to the datapath diagram as well

also make sure all the binary values use consistent font sizes, including booth_tmp and next booth_p. The formatting should remain readable regardless of the selected operand width

Test the calculations across different widths and operand combinations, including positive and negative numbers, zero and boundary cases. the intermediate register values should match our MCycle.v, not just the final multiplication result

Keep everything in one HTML file that can run directly in a browser without additional files
