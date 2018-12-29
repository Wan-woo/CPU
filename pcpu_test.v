`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:47:48 12/12/2018
// Design Name:   pcpu
// Module Name:   D:/xilinx/lab/CPU/pcpu_test.v
// Project Name:  CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: pcpu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

// pcpu_test.v
`timescale 1ns / 1ps
`include "def.v"

module pcpu_test;

	// Inputs
	reg clock;
	reg enable;
	reg reset;
	reg start;
	reg [31:0] i_datain;
	reg [31:0] d_datain;

	// Outputs
	wire [31:0] i_addr;
	wire [31:0] d_addr;
	wire d_we;
	wire [31:0] d_dataout;
	integer fp_w;
	// Instantiate the Unit Under Test (UUT)
	pcpu uut (
		.clock(clock), 
		.enable(enable), 
		.reset(reset), 
		.start(start), 
		.i_datain(i_datain), 
		.d_datain(d_datain), 
		.i_addr(i_addr), 
		.d_addr(d_addr), 
		.d_we(d_we), 
		.d_dataout(d_dataout)
	);

	initial begin
		// Initialize Inputs
		clock = 0;
		enable = 0;
		reset = 1;
		start = 0;
		i_datain = 0;
		d_datain = 0;
		//select_y = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		$display("pc :     id_ir      : reg_A : reg_B : reg_C : zf : nf : cf £ºALUo :ALUsigned :branch_flag:ex_ir");
		$monitor("%h : %b             : %h    : %h    : %h    : %b : %b : %b : %h   :%h       	: %b: %b", 
			uut.pc, uut.id_ir, uut.reg_A, uut.reg_B, uut.reg_C,
			uut.zf, uut.nf, uut.cf, uut.ALUo, uut.ALUsigned, uut.branch_flag, uut.ex_ir);
		
		enable <= 1; start <= 0; i_datain <= 0; d_datain <= 0; //select_y <= 0;

		#10 reset <= 0;
		#10 reset <= 1;
		#10 enable <= 1;
		#10 start <=1;
		#10 start <= 0;
		#10 i_datain <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
		#10 i_datain <= {`ADD, `gr2, `gr5, `gr4, 5'b00000, `ADD};
		#10 i_datain <= {`BEQ, `gr2, `gr2, 16'b0000_0000_0000_1000};
		#10 i_datain <= {`ADD, `gr4, `gr5, `gr3, 5'b00000, `ADD};
		#10 i_datain <= {`ADD, `gr6, `gr3, `gr2, 5'b00000, `ADD};
		#10 i_datain <= {`LOAD, `gr1, `gr0, 16'b0000_0100_0000_0000};
		#10 i_datain <= {`LOAD, `gr2, `gr3, 16'b0000_1100_0000_0001};
		#10 i_datain <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
		#10 i_datain <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
			d_datain <=16'h00AB;  // 3 clk later from LOAD
		#10 i_datain <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
			d_datain <=16'h3C00;  // 3 clk later from LOAD
		
		#10 i_datain <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
		#10 i_datain <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
		#10 i_datain <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
		#10 i_datain <= {`ORI, `gr2, `gr2, 16'b0000_0000_0000_0100};
		#10 i_datain <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
		#10 i_datain <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
		#10 i_datain <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
		#10 i_datain <= {`ADDi, `gr2, `gr5, `gr4, 5'b00000, `ADDi};
		#10 i_datain <= {`NOP, 26'b00_0000_0000_0000_0000_0000_0000};
		
		fp_w = $fopen("data_out.txt", "w");
		$fdisplay(fp_w, i_datain);
		$fclose(fp_w);
	end
	
	always #5
		clock = ~clock;
      
endmodule


