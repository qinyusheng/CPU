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
	output reg[`RegBus] wdata_o
);

always @(*) begin
	if(rst==`RstEnable) begin
		wd_o <= `NOPRegAddr;
		wreg_o <= `WriteDisable;
		wdata_o <= `ZeroWord;
	end else begin
		wd_o <= wd_i;
		wreg_o <= wreg_i;
		wdata_o <=wdata_i;
	end//if
end//always

endmodule
