`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/06 14:27:37
// Design Name: 
// Module Name: if_id
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


// *** IF/ID ***
/*
端口设置：
input:
	rst		复位信号
	clk		时钟信号
	if_pc	取指阶段得到的指令地址
	if_inst	取指阶段得到的指令
output:
	id_pc	译码阶段的指令对应的地址
	id_inst	译码阶段的指令
*/

module if_id(
	input wire clk,
	input wire rst,
	input wire[5:0] stall,
	
	// 获得来自取指阶段的信息
	input wire[`InstAddrBus]	if_pc,
	input wire[`InstBus]		if_inst,
	
	// 译码阶段产生的信号
	output reg[`InstAddrBus]	id_pc,
	output reg[`InstBus]		id_inst
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end else if(stall[1] == `Stop && stall[2] == `NoStop) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end else if(stall[1] == `NoStop)begin
			id_pc <= if_pc;
			id_inst <= if_inst;
		end
	end
endmodule