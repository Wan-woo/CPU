`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:38:35 12/12/2018 
// Design Name: 
// Module Name:    def 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
// def.v
`define idle	1'b0
`define exec	1'b1

`define NOP		6'b00_0000
`define HALT	6'b00_0001
`define LOAD	6'b00_0010
`define STORE	6'b00_0011
`define ADD		6'b00_1000
`define ADDi   6'b00_1001
`define SUB		6'b00_1010
`define JUMP	6'b00_1011
`define BEQ 	6'b00_1100
`define ORI   	6'b01_0001
`define ADDIU  6'b01_0010
`define ANDI   6'b01_0011
`define XORI   6'b01_0100
`define LUI    6'b01_0101
`define SLTI   6'b01_0110
`define BNE    6'b01_0111
`define BLEZ  	6'b01_1000
`define BGTZ   6'b01_1001
`define J     	6'b01_1010
`define JAL    6'b01_1011
`define JALR   6'b01_1100
`define JR     6'b01_1101
`define SLTIU  6'b01_1110

`define gr0		5'b00000
`define gr1		5'b00001
`define gr2		5'b00010
`define gr3		5'b00011
`define gr4		5'b00100
`define gr5		5'b00101
`define gr6		5'b00110
`define gr7		5'b00111
`define gr8		5'b01000
`define gr9		5'b01001
`define gr10	5'b01010
`define gr11	5'b01011
`define gr12	5'b01100
`define gr13	5'b01101
`define gr14	5'b01110
`define gr15	5'b01111
`define gr16	5'b10000
`define gr17	5'b10001
`define gr18	5'b10010
`define gr19	5'b10011
`define gr20	5'b10100
`define gr21	5'b10101
`define gr22	5'b10110
`define gr23	5'b10111
`define gr24	5'b11000
`define gr25	5'b11001
`define gr26	5'b11010
`define gr27	5'b11011
`define gr28	5'b11100
`define gr29	5'b11101
`define gr30	5'b11110
`define gr31	5'b11111