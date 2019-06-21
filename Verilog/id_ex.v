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


// ID/EX 模块
/*
端口设置：
input：
	rst 		复位信号
	clk			时钟信号
	
	id_alusel	译码阶段指令的运算类型
	id_aluop	译码阶段指令的运算子类型
	id_reg1		译码阶段进行运算的源操作数1
	id_reg2		译码阶段进行运算的源操作数2
	id_wd		译码阶段要写入的寄存器地址
	id_wreg		译码阶段是否需要将结果写入寄存器

output：
	ex_alusel	执行阶段指令的运算类型
	ex_aluop	执行阶段指令的运算子类型
	ex_reg1		执行阶段指令的运算的操作数1
	ex_reg2		执行阶段指令的运算的操作数2
	ex_wd		执行阶段的指令要写入的目的寄存器地址
	ex_wreg		执行阶段的指令是否需要将结果写入寄存器
*/

module id_ex(
	input wire		clk,
	input wire		rst,
	
	// 从译码阶段传递来的消息
	input wire[`AluOpBus]	id_aluop,
	input wire[`AluSelBus]	id_alusel,
	input wire[`RegBus]		id_reg1,
	input wire[`RegBus]		id_reg2,
	input wire[`RegAddrBus]	id_wd,
	input wire				id_wreg,
	
	// 传递到执行阶段的信息
	output reg[`AluOpBus]	ex_aluop,
	output reg[`AluSelBus]	ex_alusel,
	output reg[`RegBus]		ex_reg1,
	output reg[`RegBus]		ex_reg2,
	output reg[`RegAddrBus]	ex_wd,
	output reg 				ex_wreg,
	
	// 系统控制指令
	input wire[5:0]			stall,
	
	// 分支跳转指令
	input wire[`RegBus]		id_link_address,
	input wire 				id_is_in_delayslot,
	input wire 				next_inst_in_delayslot_i,
	
	output reg[`RegBus]		ex_link_address,
	output reg				ex_is_in_delayslot,
	output reg				is_in_delayslot_o,
	
	// 加载与写入
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