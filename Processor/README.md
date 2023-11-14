# Processor
## Adam Ebrahim (aae39)

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
