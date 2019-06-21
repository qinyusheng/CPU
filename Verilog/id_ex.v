`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/06 14:27:37
// Design Name: 
// Module Name: id_ex
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


// ID/EX ģ��
/*
�˿����ã�
input��
	rst 		��λ�ź�
	clk			ʱ���ź�
	
	id_alusel	����׶�ָ�����������
	id_aluop	����׶�ָ�������������
	id_reg1		����׶ν��������Դ������1
	id_reg2		����׶ν��������Դ������2
	id_wd		����׶�Ҫд��ļĴ�����ַ
	id_wreg		����׶��Ƿ���Ҫ�����д��Ĵ���

output��
	ex_alusel	ִ�н׶�ָ�����������
	ex_aluop	ִ�н׶�ָ�������������
	ex_reg1		ִ�н׶�ָ�������Ĳ�����1
	ex_reg2		ִ�н׶�ָ�������Ĳ�����2
	ex_wd		ִ�н׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ
	ex_wreg		ִ�н׶ε�ָ���Ƿ���Ҫ�����д��Ĵ���
*/

module id_ex(
	input wire		clk,
	input wire		rst,
	
	// ������׶δ���������Ϣ
	input wire[`AluOpBus]	id_aluop,
	input wire[`AluSelBus]	id_alusel,
	input wire[`RegBus]		id_reg1,
	input wire[`RegBus]		id_reg2,
	input wire[`RegAddrBus]	id_wd,
	input wire				id_wreg,
	
	// ���ݵ�ִ�н׶ε���Ϣ
	output reg[`AluOpBus]	ex_aluop,
	output reg[`AluSelBus]	ex_alusel,
	output reg[`RegBus]		ex_reg1,
	output reg[`RegBus]		ex_reg2,
	output reg[`RegAddrBus]	ex_wd,
	output reg 				ex_wreg,
	
	// ϵͳ����ָ��
	input wire[5:0]			stall,
	
	// ��֧��תָ��
	input wire[`RegBus]		id_link_address,
	input wire 				id_is_in_delayslot,
	input wire 				next_inst_in_delayslot_i,
	
	output reg[`RegBus]		ex_link_address,
	output reg				ex_is_in_delayslot,
	output reg				is_in_delayslot_o,
	
	// ������д��
	input wire[`RegBus]		id_inst,
	output reg[`RegBus] 	ex_inst
);

always @ (posedge clk) begin
	if (rst == `RstEnable) begin
		ex_aluop 	<= `EXE_NOP_OP;
		ex_alusel	<= `EXE_RES_NOP;
		ex_reg1		<= `ZeroWord;
		ex_reg2		<= `ZeroWord;
		ex_wd 		<= `NOPRegAddr;
		ex_wreg		<= `WriteDisable;
	end else if(stall[2] == `Stop && stall[3] == `NoStop) begin
		ex_aluop 	<= `EXE_NOP_OP;
		ex_alusel	<= `EXE_RES_NOP;
		ex_reg1		<= `ZeroWord;
		ex_reg2		<= `ZeroWord;
		ex_wd 		<= `NOPRegAddr;
		ex_wreg		<= `WriteDisable;
	end else if (stall[2] == `NoStop) begin
		ex_aluop    <= id_aluop;
		ex_alusel	<= id_alusel;
		ex_reg1		<= id_reg1;
		ex_reg2		<= id_reg2;
		ex_wd 		<= id_wd;
		ex_wreg		<= id_wreg;
		ex_link_address	<= id_link_address;
		ex_is_in_delayslot	<= id_is_in_delayslot;
		is_in_delayslot_o	<= next_inst_in_delayslot_i;
		ex_inst 	<= id_inst;
	end
end

endmodule