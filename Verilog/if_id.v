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
�˿����ã�
input:
	rst		��λ�ź�
	clk		ʱ���ź�
	if_pc	ȡָ�׶εõ���ָ���ַ
	if_inst	ȡָ�׶εõ���ָ��
output:
	id_pc	����׶ε�ָ���Ӧ�ĵ�ַ
	id_inst	����׶ε�ָ��
*/

module if_id(
	input wire clk,
	input wire rst,
	input wire[5:0] stall,
	
	// �������ȡָ�׶ε���Ϣ
	input wire[`InstAddrBus]	if_pc,
	input wire[`InstBus]		if_inst,
	
	// ����׶β������ź�
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