`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:39:54 12/12/2018 
// Design Name: 
// Module Name:    pcpu 
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
// pcpu.v
`timescale 1ns / 1ps
`include "def.v"

module pcpu(
    input clock,
    input enable,
    input reset,
    input start,
    input [31:0] i_datain,
    input [31:0] d_datain,
    output [31:0] i_addr,
    output [31:0] d_addr,
    output d_we,
    output [31:0] d_dataout
    );

	reg cf_buf;
	reg [31:0] ALUo;
	reg state, next_state;
	reg zf, nf, cf, dw;
	reg [31:0] pc;
	reg [4:0] shamt;
	reg [31:0] id_ir, ex_ir, mem_ir, wb_ir;
	reg [31:0] reg_A, reg_B, reg_C, reg_mem, reg_C1, reg_wb, smdr, smdr1;
	reg [31:0] LMD, Imm;
	reg [25:0] JumpAddr;
	reg signed [31:0] A_signed, B_signed, ALUsigned;
	reg [31:0] gr[7:0];
	reg [31:0] MEM[1023:0];
	wire branch_flag;
	wire [31:0] ins;
	reg [31:0] ir[11:0];
	
	//********读入****************************//
	//initial $readmemb("data_in.txt",ir);
	
	instruction iri(clock,reset,pc,ins);
	
	//************* CPU Control *************//
	always @(posedge clock)
		begin
			if (!reset)
				state <= `idle;
			else
				state <= next_state;
		end
	
	//************* CPU Control *************//
	always @(*)
		begin
			case (state)
				`idle : 
					if ((enable == 1'b1) 
							&& (start == 1'b1))
						next_state <= `exec;
					else	
						next_state <= `idle;
				`exec :
					if ((enable == 1'b0) 
							|| (wb_ir[31:26] == `HALT))
						next_state <= `idle;
					else
						next_state <= `exec;
			endcase
		end
		
		
		
	//************* IF *************//
	assign i_addr = pc;
	always @(posedge clock or negedge reset)
		begin
			
			if (!reset)
				begin
					id_ir <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
					pc <= 32'h0000_0000;
				end
				
			else if (state ==`exec)
				begin
				    //id_ir <= ir[pc];        //以txt方式读入
				   id_ir <= ins;
					//一开始即检测load冲突
					//新的指令要使用到了load写入的寄存器
					if((id_ir[31:26] == `LOAD)
					&&(((i_datain[20:16] == id_ir[25:21])&&(I_TYPE(i_datain[31:26])))
					||((i_datain[20:16] == id_ir[25:21])&&(R_TYPE(i_datain[31:26])))
					||((i_datain[15:11] == id_ir[25:21])&&(R_TYPE(i_datain[31:26])))
					)) 
					begin
						pc <= pc;
						id_ir <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
					end
					
					if(branch_flag)
					begin
						pc <= ALUo;
						id_ir <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
					end
					else
						pc <= pc + 1;
				end
		end
		
		
	//************* ID *************//
	always @(posedge clock or negedge reset)
		begin
			if (!reset)
				begin
					ex_ir <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
					reg_A <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					reg_B <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					reg_C <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					smdr <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
				end
			
			else if (state == `exec)
				begin
					ex_ir <= id_ir;
					Imm <= id_ir[15:0];
					if(branch_flag)
					ex_ir <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
					
					if(I_TYPE(id_ir[31:26]))
						begin
							reg_A <= gr[id_ir[25:21]];
							reg_B <= gr[id_ir[20:16]];
						end
					else if(R_TYPE(id_ir[31:26]))
						begin
							reg_A <= gr[id_ir[25:21]];
							reg_B <= gr[id_ir[20:16]];
							reg_C <= gr[id_ir[15:11]];
						end
					else if(J_TYPE(id_ir[31:26]))
						JumpAddr <= id_ir[25:0];
					//检测冲突，避免错误的赋值
					if((I_TYPE(id_ir[31:26])&&I_TYPE(ex_ir[31:26]))||(I_TYPE(id_ir[31:26])&&I_TYPE(mem_ir[31:26]))||(I_TYPE(id_ir[31:26])&&I_TYPE(wb_ir[31:26])))
					begin
						if(id_ir[25:21] == ex_ir[20:16])
							reg_A <= ALUo;
						else if(id_ir[25:21] == mem_ir[20:16])
							reg_A <= reg_mem;
						else if(id_ir[25:21] == wb_ir[20:16])
							reg_A <= reg_wb;
					end
					else if((I_TYPE(id_ir[31:26])&&R_TYPE(ex_ir[31:26]))||(I_TYPE(id_ir[31:26])&&R_TYPE(mem_ir[31:26]))||(I_TYPE(id_ir[31:26])&&R_TYPE(wb_ir[31:26])))
					begin
						if(id_ir[25:21] == ex_ir[15:11])
							reg_A <= ALUo;
						else if(id_ir[25:21] == mem_ir[15:11])
							reg_A <= reg_mem;
						else if(id_ir[25:21] == wb_ir[15:11])
							reg_A <= reg_wb;
					end
					else if((R_TYPE(id_ir[31:26])&&I_TYPE(ex_ir[31:26]))||(R_TYPE(id_ir[31:26])&&I_TYPE(mem_ir[31:26]))||(R_TYPE(id_ir[31:26])&&I_TYPE(wb_ir[31:26])))
					begin
						if(id_ir[25:21] == ex_ir[20:16])
							reg_A <= ALUo;
						else if(id_ir[25:21] == mem_ir[20:16])
							reg_A <= reg_mem;
						else if(id_ir[25:21] == wb_ir[20:16])
							reg_A <= reg_wb;
						else if(id_ir[20:16] == ex_ir[20:16])
							reg_B <= ALUo;
						else if(id_ir[20:16] == mem_ir[20:16])
							reg_B <= reg_mem;
						else if(id_ir[20:16] == wb_ir[20:16])
							reg_B <= reg_wb;
					end
					else if((R_TYPE(id_ir[31:26])&&R_TYPE(ex_ir[31:26]))||(R_TYPE(id_ir[31:26])&&R_TYPE(mem_ir[31:26]))||(R_TYPE(id_ir[31:26])&&R_TYPE(wb_ir[31:26])))
					begin
						if(id_ir[25:21] == ex_ir[15:11])
							reg_A <= ALUo;
						else if(id_ir[25:21] == mem_ir[15:11])
							reg_A <= reg_mem;
						else if(id_ir[25:21] == wb_ir[15:11])
							reg_A <= reg_wb;
						else if(id_ir[20:16] == ex_ir[15:11])
							reg_B <= ALUo;
						else if(id_ir[20:16] == mem_ir[15:11])
							reg_B <= reg_mem;
						else if(id_ir[20:16] == wb_ir[15:11])
							reg_B <= reg_wb;
					end
					
				end
		end

	//************* EX *************//
	always @(posedge clock or negedge reset)
		begin
			if (!reset)
				begin
					mem_ir <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
					//reg_C <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					smdr1 <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					//nf <= 1'b0;
				end
			
			else if (state == `exec)
				begin
					reg_mem <= ALUo;
					mem_ir <= ex_ir;
					if(branch_flag)
					mem_ir <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
					/*
					if((mem_ir[31:26] == `J)
								||(ex_ir[31:26] == `JAL)
								||(ex_ir[31:26] == `JALR)
								||(ex_ir[31:26] == `JR)
								||((ex_ir[31:26] == `BEQ)&&(nf == 1'b1))
								||((ex_ir[31:26] == `BNE)&&(nf == 1'b1))
								||((ex_ir[31:26] == `BLEZ)&&(nf == 1'b1))
								||((ex_ir[31:26] == `BGTZ)&&(nf == 1'b1))
						)
						begin
						pc <= ALUo;
						mem_ir <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
						end
						*/
				end
		end
	always @(*)
		begin
			if(I_TYPE(ex_ir[31:26]))
					begin
					
						case(ex_ir[31:26])
							`STORE: ALUo <= reg_B + reg_A;//store & load only
							`LOAD:  ALUo <= reg_B + reg_A;//store & load only
							`ORI:
								ALUo <= reg_A | Imm;
							`ADDIU:
								ALUo <= reg_A + Imm; //??
							`ANDI:
								ALUo <= reg_A & Imm;
							`XORI:
								ALUo <= reg_A ^ Imm;
							`LUI:
								ALUo <= {Imm, 16'b0};
							`SLTI:
								ALUo <= (reg_A < Imm) ? 1 : 0; //有符号暂未实现
							`SLTIU:
								ALUo <= (reg_A < Imm) ? 1 : 0;
							
							`BEQ:
								begin
									if(reg_A == reg_B)
									begin
										ALUo <= pc + Imm; 
										nf <= 1'b1;
									end
								end
							`BNE:
								begin
									if(reg_A != reg_B)
									begin
										ALUo <= pc + Imm; 
										nf <= 1'b1;
									end
								end
							`BLEZ:
								begin
									if(reg_A <= 0)
									begin
										ALUo <= pc + Imm;
										nf <= 1'b1;
									end
								end
							`BGTZ:
								begin
									if(reg_A > 0)
									begin
										ALUo <= pc + Imm;
										nf <= 1'b1;
									end
								end
							default: nf <= 1'b0;
						endcase	
						
					end
			else if(R_TYPE(ex_ir[31:26]))
					begin
						case(ex_ir[5:0])
							`ADD: ALUo <= reg_B + reg_A;
							`SUB: ALUo <= reg_B - reg_A;
							`ADDi: 
								begin
									  ALUsigned <= $signed(reg_A) + $signed(reg_B);
								end
							default:;
						endcase
					end
			else if(J_TYPE(ex_ir[31:26]))
					begin
					
						case(ex_ir[31:26])
							`J:		ALUo <= pc + JumpAddr;
							`JAL:		ALUo <= pc + JumpAddr;    // GPR[31] <= pc + 4
							`JALR: 	
									begin
										ALUo <= reg_A; 	//pc不能使用
										ALUo <= pc + 4;  //reg_B不能使用
									end
							`JR:
										ALUo <= reg_A;
							default:;
						endcase
					end
		end

	//************* MEM *************//
	assign d_addr = reg_C[7:0];
	assign d_we = dw;
	assign d_dataout = smdr1;
	assign branch_flag = ((ex_ir[31:26] == `J)
								||(ex_ir[31:26] == `JAL)
								||(ex_ir[31:26] == `JALR)
								||(ex_ir[31:26] == `JR)
								||((ex_ir[31:26] == `BEQ)&&(nf == 1'b1))
								||((ex_ir[31:26] == `BNE)&&(nf == 1'b1))
								||((ex_ir[31:26] == `BLEZ)&&(nf == 1'b1))
								||((ex_ir[31:26] == `BGTZ)&&(nf == 1'b1))
						);
	
	always @(posedge clock or negedge reset)
		begin
			if (!reset)
				begin
					wb_ir <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
					reg_C1 <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
				end
			
			else if (state == `exec)
				begin
					wb_ir <= mem_ir;
					reg_wb <= reg_mem;
					if (mem_ir[31:26] == `LOAD)
						LMD <= MEM[ALUo];
					else if(mem_ir[31:26] == `STORE)
						MEM[ALUo] <= reg_A;
				end
		end
			
	//************* WB *************//
	always @(posedge clock or negedge reset)
		begin
			if (!reset)
				begin
					gr[0] <= 32'h0000_0000;
					gr[1] <= 32'h0000_0001;
					gr[2] <= 32'h0000_0010;
					gr[3] <= 32'h0000_00a0;
					gr[4] <= 32'h0000_0f00;
					gr[5] <= 32'hf000_000f;
					gr[6] <= 32'h0000_000f;
				end
			
			else if (state == `exec)
				begin
					if (I_TYPE(wb_ir[31:26]))
					begin
						if(wb_ir[31:26] == `LOAD)
							gr[wb_ir[20:16]] <= LMD;
					end
					if(RR_TYPE(wb_ir[31:26]))
						gr[wb_ir[20:16]] <= reg_wb;
					else if(RI_TYPE(wb_ir[31:26]))
						gr[wb_ir[15:11]] <= reg_wb; 
				end
		end
		//*****I_TYPE*********************************************//
		function I_TYPE;
			input [5:0] op;
			begin
				I_TYPE = ((op == `LOAD)
						|| (op == `STORE)
						|| (op == `BEQ)
						|| (op == `ORI));
			end
		endfunction
		
		//*****R_TYPE*********************************************//
		function R_TYPE;
			input [5:0] op;
			begin 
				R_TYPE = ((op == `ADD)
						|| (op == `SUB)
						|| (op == `ADDi));
			end
		endfunction
		
		//*****J_TYPE*********************************************//
		function J_TYPE;
			input [5:0] op;
			begin
				J_TYPE = (op == `JUMP);
			end
		endfunction
		
		//*****RR_TYPE********************************************//
		function RR_TYPE;
			input [5:0] op;
			begin
				RR_TYPE = (op == `ADD);
			end
		endfunction
	
		//*****RI_TYPE********************************************//
		function RI_TYPE;
			input [5:0] op;
			begin
				RI_TYPE = (op == `ADDi);
			end
		endfunction

endmodule