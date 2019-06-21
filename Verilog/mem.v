`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/06 14:27:37
// Design Name: 
// Module Name: mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


/*MEM模块
接口描述 
复位信号（输入）	rst
访存阶段的指令要写入的目的寄存器（输入）	wd_i
访存阶段的指令是否要写入目的寄存器（输入）	wreg_i
访存阶段的指令写入目的存器的值（输入）	wdata_i
最终写入的目的寄存器的地址（输出）	wd_o
最终是否要写入目的寄存器（输出）	wreg_o
最终写入目的寄存器的值（输出）	wdata_o
*/

module mem(
	input wire rst,//复位信号
	
	input wire[`RegAddrBus] wd_i,
	input wire wreg_i,
	input wire[`RegBus] wdata_i,
	
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus] wdata_o,
	
	// 加载与写入功能
	input wire[`AluOpBus]	aluop_i,
	input wire[`RegBus]		mem_addr_i,
	input wire[`RegBus]		reg2_i,
	
	input wire[`RegBus]		mem_data_i, // 接受存储器RAM的信息
	
	// 传输到外部存储器RAM的信息
	output reg[`RegBus]		mem_addr_o,
	output wire				mem_we_o,
	output reg[3:0]			mem_sel_o,
	output reg[`RegBus]		mem_data_o,
	output reg				mem_ce_o
);

wire[`RegBus]	zero32;
reg				mem_we;

assign mem_we_o = mem_we; // 外部存储器读写信号
assign zero32  	= `ZeroWord;

always @(*) begin
	if(rst==`RstEnable) begin
		wd_o 		<= `NOPRegAddr;
		wreg_o 		<= `WriteDisable;
		wdata_o	 	<= `ZeroWord;
		mem_addr_o 	<= `ZeroWord;
		mem_we		<= `WriteDisable;
		mem_sel_o   <= 4'b0000;
		mem_data_o 	<= `ZeroWord;
		mem_ce_o	<= `ChipDisable;
	end else begin
		wd_o 		<= wd_i;
		wreg_o		<= wreg_i;
		wdata_o 	<= wdata_i;
		mem_we		<= `WriteDisable;
		mem_addr_o	<= `ZeroWord;
		mem_sel_o	<= 4'b1111;
		mem_ce_o	<= `ChipDisable;
		case (aluop_i)
			`EXE_LW_OP: begin
				mem_addr_o	<= mem_addr_i;
				mem_we		<= `WriteDisable;
				wdata_o		<= mem_data_i;
				mem_sel_o	<= 4'b1111;
				mem_ce_o	<= `ChipEnable;
			end
			`EXE_SW_OP: begin
				mem_addr_o  <= mem_addr_i;
				mem_we		<= `WriteEnable;
				mem_data_o	<= reg2_i;
				mem_sel_o	<= 4'b1111;
				mem_ce_o	<= `ChipEnable;
			end

			default: begin
			end
		endcase
	end//if
end//always

endmodule
