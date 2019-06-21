`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/06 14:27:37
// Design Name: 
// Module Name: inst_rom
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


// ָ��洢��
/*
�˿�����:
input:
	ce			ʹ���ź�
	addr		Ҫ��ȡ��ָ���ַ
output:
	inst		������ָ��
*/

module inst_rom(
	input wire		ce,
	input wire[`InstAddrBus]	addr,
	output reg[`InstBus]		inst
);
	
	// ����һ�����飬��С��InstMemNum��Ԫ�ؿ��ΪInstBus
	reg[`InstBus]		inst_mem[0 : `InstMemNum-1];
	
	// ���ļ�inst_rom.data�ж�ȡָ��
	initial $readmemh ("D:/inst_rom.data", inst_mem);
	
	// ����λ�ź���Чʱ�����������ַ��������Ӧ��Ԫ��
	always @ (*) begin
		if(ce == `ChipDisable) begin
			inst <= `ZeroWord;
		end else begin
			inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
		end
	end
endmodule
