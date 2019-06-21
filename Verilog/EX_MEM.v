`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/06 14:27:37
// Design Name: 
// Module Name: ex_mem
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

//EX/MEM模块：将从执行阶段取得的运算结果在下一个时钟传递到流水线的访存阶段
//接口信息
//复位信号（输入）	rst
//时钟信号（输入）	clk
//执行阶段的指令执行后要写入的寄存器的地址（输入）	ex_wd
//执行阶段的指令执行后是否有要写入的寄存器（输入）	ex_wreg 
//执行阶段的指令执行后要写入的寄存器的值（输入）	ex_wdata
//访存阶段要写入的寄存器的地址（输出）	mem_wd
//访存阶段是否要写入目的寄存器（输出）	mem_wreg
//访存阶段的指令要写入的目的寄存器的值（输出） mem_wdata

module ex_mem(
	//时钟信号和复位信号
	input wire clk,
	input wire rst,
	//来自于执行阶段的信息
	input wire[`RegAddrBus] ex_wd,
	input wire ex_wreg,
	input wire[`RegBus] ex_wdata,
	//要送达到访存阶段的信息
	output reg[`RegAddrBus] mem_wd,
	output reg mem_wreg,
	output reg[`RegBus] mem_wdata,
	
	// 系统控制指令
	input wire[5:0]			stall,
	
	// 加载与写入
	input wire[`AluOpBus] 	ex_aluop,
	input wire[`RegBus]		ex_mem_addr,
	input wire[`RegBus]		ex_reg2,
	
	output reg[`AluOpBus]	mem_aluop,
	output reg[`RegBus]		mem_mem_addr,
	output reg[`RegBus]		mem_reg2
);

always @ (posedge clk) begin
	if(rst==`RstEnable) begin
		mem_wd 		<= `NOPRegAddr;
		mem_wreg 	<= `WriteDisable;
		mem_wdata 	<= `ZeroWord;
		mem_aluop	<= `EXE_NOP_OP;
		mem_mem_addr <= `ZeroWord;
		mem_reg2	<= `ZeroWord;
	end else if(stall[3] == `Stop && stall[4] == `NoStop) begin
		mem_wd <= `NOPRegAddr;
		mem_wreg <= `WriteDisable;
		mem_wdata <= `ZeroWord;
		mem_aluop	<= `EXE_NOP_OP;
		mem_mem_addr <= `ZeroWord;
		mem_reg2	<= `ZeroWord;
	end else if(stall[3] == `NoStop)begin
		mem_wd <= ex_wd;
		mem_wreg <= ex_wreg;
		mem_wdata <= ex_wdata;
		mem_aluop	<= ex_aluop;
		mem_mem_addr <= ex_mem_addr;
		mem_reg2	<= ex_reg2;
	end else begin
		mem_wd 		<= `NOPRegAddr;
		mem_wreg 	<= `WriteDisable;
		mem_wdata 	<= `ZeroWord;
		mem_aluop	<= `EXE_NOP_OP;
		mem_mem_addr <= `ZeroWord;
		mem_reg2	<= `ZeroWord;
	end
end//always

endmodule

