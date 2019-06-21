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

//EX/MEMģ�飺����ִ�н׶�ȡ�õ�����������һ��ʱ�Ӵ��ݵ���ˮ�ߵķô�׶�
//�ӿ���Ϣ
//��λ�źţ����룩	rst
//ʱ���źţ����룩	clk
//ִ�н׶ε�ָ��ִ�к�Ҫд��ļĴ����ĵ�ַ�����룩	ex_wd
//ִ�н׶ε�ָ��ִ�к��Ƿ���Ҫд��ļĴ��������룩	ex_wreg 
//ִ�н׶ε�ָ��ִ�к�Ҫд��ļĴ�����ֵ�����룩	ex_wdata
//�ô�׶�Ҫд��ļĴ����ĵ�ַ�������	mem_wd
//�ô�׶��Ƿ�Ҫд��Ŀ�ļĴ����������	mem_wreg
//�ô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����ֵ������� mem_wdata

module ex_mem(
	//ʱ���źź͸�λ�ź�
	input wire clk,
	input wire rst,
	//������ִ�н׶ε���Ϣ
	input wire[`RegAddrBus] ex_wd,
	input wire ex_wreg,
	input wire[`RegBus] ex_wdata,
	//Ҫ�ʹﵽ�ô�׶ε���Ϣ
	output reg[`RegAddrBus] mem_wd,
	output reg mem_wreg,
	output reg[`RegBus] mem_wdata,
	
	// ϵͳ����ָ��
	input wire[5:0]			stall,
	
	// ������д��
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

