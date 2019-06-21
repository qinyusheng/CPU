`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/06 14:27:37
// Design Name: 
// Module Name: pc
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

// *** PCģ�� ***
/* 
�˿����ã�
input:
	rst ��λ�ź����
	clk ʱ���ź����
output:
	pc ��ȡ��ָ��ĵ�ַ���ڼ���ָ��
	ce ָ��洢��ʹ���ź�
*/
// ģ��˼·
/*
	rst��λ�ź���Чʱָ��洢�����ã���ʱpc�õ���ָ���ַΪ��
	rstָ���ź���Чʱ����ģ����������
*/

module pc_reg(
	input wire clk,
	input wire rst,
	
	input wire[5:0]		stall, // ���Կ���ģ��CTRL
	
	// ����IDģ�����Ϣ��ʵ�ַ�֧��ת����
	input wire 			branch_flag_i,
	input wire[`RegBus]	branch_target_address_i,
	
	output reg[`InstAddrBus] pc,
	output reg ce
);
	// �����ش���
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ce <= `ChipDisable;
		end else begin	
			ce <= `ChipEnable;
		end
	end
	
	always @ (posedge clk) begin
		if (ce == `ChipDisable) begin
			pc <= 32'h00000000;
		end
		else if(stall[0] == `NoStop) begin
			if(branch_flag_i == `Branch) begin
				pc <= branch_target_address_i;
			end else begin
				pc <= pc + 4'h4;
			end
		end
	end

endmodule

