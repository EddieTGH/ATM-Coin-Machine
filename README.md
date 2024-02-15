# ATM Coin Machine
This repository contains all code related to a functioning Coin ATM created as a final project in ECE 350 at Duke University. The ATM supports different accounts accessible by entering a unique 4-digit pin, viewing current account balance, and depositing/withdrawing coins (along with error checking in case of insufficient balance). A video of the ATM in action is shown below: 



https://github.com/AdamEbrahim/ATMCoinMachine/assets/110650531/b5d238b4-5405-41a9-8a0e-f05fcb8a8726

Various images of the wiring and mechanical components of the device are shown below:

<img width="318" alt="atmstuff2" src="https://github.com/AdamEbrahim/ATMCoinMachine/assets/110650531/170ad19b-4a8c-4335-b401-3aed6129e2ce">

<img width="318" alt="IMG_0831" src="https://github.com/AdamEbrahim/ATMCoinMachine/assets/110650531/b07655ef-06c6-4688-861a-8ec9b8b18443">

<img width="318" alt="IMG_0833" src="https://github.com/AdamEbrahim/ATMCoinMachine/assets/110650531/d22b05e3-dc3d-4d90-98af-ada985bd5f72">

<img width="318" alt="IMG_0825" src="https://github.com/AdamEbrahim/ATMCoinMachine/assets/110650531/cbd8604a-af12-4723-af6e-3773333bcf4d">

<img width="318" height="425" alt="atmstuff3" src="https://github.com/AdamEbrahim/ATMCoinMachine/assets/110650531/fecb5bc6-ae25-4e63-b6bc-c3ee112cefc1">

<img width="318" alt="atmstuff" src="https://github.com/AdamEbrahim/ATMCoinMachine/assets/110650531/2bbf69f5-2848-4406-a31b-bf26b7756ddc">


To control this device, a Nexys A7-100T FPGA was programmed with a 5-stage pipelined CPU written entirely from scratch in Verilog, designed to operate at a 50 MHz clock speed. The FPGA also contained 4 KB of word-addressed RAM for the CPU to access, and MMIO was used to perform various device I/O. Different peripheral devices for this project included servos, beam break sensors, a keypad, LEDs, and a seven-segment display. The assembly program that controls the coin ATM through its various states was written in MIPS.   

# Processor
## Adam Ebrahim

## Description of Design
This is a 5-stage pipelined CPU written in Verilog that supports the ECE 350 ISA. The 5 stages are as follows: Fetch, Decode, Execute, Memory, and Writeback. In between each stage is a series of latches to support concurrent operations across the different stages. The Fetch stage is where the correct instruction from instruction memory is acquired. The Program Counter is what is used as the address for instruction memory, and it can either be PC = PC + 1 in the default case, or some other PC if there is some sort of control or jumping logic. The Decode stage is where the instruction is decoded (which allows different control signals to be created for the following stages) and the correct registers are read from the register file. The Execute stage is where the ALU performs the correct operation on the operands, with support for multiplication and division through a separate multdiv module. Branching and jumping logic is also resolved in this stage, which will change the Program Counter register. If some control logic is taken that changes the PC in a way that isn't just incrementing it, the current instructions in the previous stages of the pipelined CPU are also flushed with nops to ensure correct control flow. The Memory stage is where the data memory is accessed if necessary, whether that be a write (sw) or a read (lw). The Writeback stage is where the result of the operation is written back to the register file to the correct register.

## Bypassing
The CPU supports different types of bypassing. Firstly, the data getting written to the register file in the Writeback stage can be bypassed into the data input for the Memory stage. This allows a store word instruction to occur right after a load word that changes the register whose value is getting stored into data memory. Additionally, the data getting written to the register file in the Writeback stage can be bypassed into either of the data inputs for the Execute stage. This allows an instruction that uses the result of the previous instruction to occur right after the previous instruction. 

## Stalling
The CPU has one stall condition, which is when there is a load output (in the memory stage) that needs to be used for the next instruction's ALU input. This is because the memory access takes too long to complete, so the next instruction's ALU input will be incorrect if it is not stalled. This includes branching logic because the ALU must compute $rd - $rs. The stall is implemented by turning off write enable for the PC register and the latches between the Fetch and Decode stages. Additionally, a nop is written into the latch between the Decode and Execute stages to ensure that the correct instruction is executed after the stall is over.

## Optimizations
The main optimizations of this CPU include bypassing and pipelining.

## Bugs
There are currently no bugs that I am aware of.
