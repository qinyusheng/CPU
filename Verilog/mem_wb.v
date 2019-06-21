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


/*MEM/WBģ��
�ӿ����� 
ʱ���źţ����룩	clk
��λ�źţ����룩	rst
�ô�׶ε�ָ������Ҫд���Ŀ�ļĴ�����ַ�����룩	mem_wd
�ô�׶ε�ָ���Ƿ�Ҫд��Ŀ�ļĴ��������룩	mem_wreg
�ô�׶ε�ָ��д��Ŀ�Ĵ�����ֵ�����룩	mem_wdata
����д���Ŀ�ļĴ����ĵ�ַ�������	wb_wd
�����Ƿ�Ҫд��Ŀ�ļĴ����������	wb_wreg
����д��Ŀ�ļĴ�����ֵ�������	wb_wdata
*/

module mem_wb
(
	input wire rst,//��λ�ź�
	input wire clk,//ʱ���ź�
	
	input wire[`RegAddrBus] mem_wd,
	input wire mem_wreg,
	input wire[`RegBus] mem_wdata,
	
	output reg[`RegAddrBus] wb_wd,
	output reg wb_wreg,
	output reg[`RegBus] wb_wdata,
	
	// ϵͳ����ָ��
	input wire[5:0]			stall
);

always @(posedge clk) begin
	if(rst==`RstEnable) begin
		wb_wd <= `NOPRegAddr;
		wb_wreg <= `WriteDisable;
		wb_wdata <= `ZeroWord;
	end else if(stall[4] == `Stop && stall[5] == `NoStop) begin
		wb_wd <= `NOPRegAddr;
		wb_wreg <= `WriteDisable;
		wb_wdata <= `ZeroWord;
	end else if(stall[4] == `NoStop) begin
		wb_wd <= mem_wd;
		wb_wreg <= mem_wreg;
		wb_wdata <= mem_wdata;
	end//if
end//always

endmodule
