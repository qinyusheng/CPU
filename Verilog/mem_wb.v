`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/06 14:27:37
// Design Name: 
// Module Name: mem_wb
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


/*MEM/WB模块
接口描述 
时钟信号（输入）	clk
复位信号（输入）	rst
访存阶段的指令最终要写入的目的寄存器地址（输入）	mem_wd
访存阶段的指令是否要写入目的寄存器（输入）	mem_wreg
访存阶段的指令写入目的存器的值（输入）	mem_wdata
最终写入的目的寄存器的地址（输出）	wb_wd
最终是否要写入目的寄存器（输出）	wb_wreg
最终写入目的寄存器的值（输出）	wb_wdata
*/

module mem_wb
(
	input wire rst,//复位信号
	input wire clk,//时钟信号
	
	input wire[`RegAddrBus] mem_wd,
	input wire mem_wreg,
	input wire[`RegBus] mem_wdata,
	
	output reg[`RegAddrBus] wb_wd,
	output reg wb_wreg,
	output reg[`RegBus] wb_wdata
);

always @(posedge clk) begin
	if(rst==`RstEnable) begin
		wb_wd <= `NOPRegAddr;
		wb_wreg <= `WriteDisable;
		wb_wdata <= `ZeroWord;
	end else begin
		wb_wd <= mem_wd;
		wb_wreg <= mem_wreg;
		wb_wdata <= mem_wdata;
	end//if
end//always

endmodule
