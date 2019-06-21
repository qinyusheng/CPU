`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/06 14:27:37
// Design Name: 
// Module Name: regfile
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


// Regfileģ��
/*
�˿����ã�
input��
	rst		��λ�ź�
	clk		ʱ���ź�
	waddr	д�����ļĴ�����ַ
	wdata	Ҫд�������
	we		д������ʹ���ź�
	raddr1	�������ĵ�һ���Ĵ����ĵ�ַ
	re1		��һ����������ʹ���ź�
	raddr2	�������ĵڶ����Ĵ����ĵ�ַ
	re2		�ڶ�����������ʹ���ź�
output��
	rdata1	�����ĵ�һ��ֵ
	rdata2	�����ĵڶ���ֵ
*/

module regfile(
	input wire	clk,
	input wire	rst,
	
	// д�˿�
	input wire				we,
	input wire[`RegAddrBus]	waddr,
	input wire[`RegBus]		wdata,
	
	// ���˿�1
	input wire				re1,
	input wire[`RegAddrBus]	raddr1,
	output reg[`RegBus]	rdata1,
	
	// ���˿�2
	input wire 				re2,
	input wire[`RegAddrBus]	raddr2,
	output reg[`RegBus]	rdata2
);

// ����32��32λ�ļĴ���������ģ��洢��
reg[`RegBus] regs[0: `RegNum-1];

// ����д����

	always @ (posedge clk) begin
		if (rst == `RstDisable) begin
			if ((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
				regs[waddr] <= wdata;
			end
		end
	end
	
// �����һ��������

	always @ (*) begin
		if (rst == `RstEnable) begin
			rdata1 <= `ZeroWord;
		end else if(raddr1 == `RegNumLog2'h0) begin
			rdata1 <= `ZeroWord;
		end else if((raddr1 == waddr) 
					&& (we == `WriteEnable)
					&& (re1 == `ReadEnable)) begin
			rdata1 <= wdata;
		end else if(re1 == `ReadEnable) begin
			rdata1 <= regs[raddr1];
		end else begin
			rdata1 <= `ZeroWord;
		end
	end
	
// ����ڶ���������
	
	always @ (*) begin
		if (rst == `RstEnable) begin
			rdata2 <= `ZeroWord;
		end else if(raddr2 == `RegNumLog2'h0) begin
			rdata2 <= `ZeroWord;
		end else if((raddr2 == waddr)
					&& (we == `WriteEnable)
					&& (re2 == `ReadEnable)) begin
			rdata2 <= wdata;
		end else if(re2 == `ReadEnable) begin
			rdata2 <= regs[raddr2];
		end else begin
			rdata2 <= `ZeroWord;
		end
	end

endmodule


