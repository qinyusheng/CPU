`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/06 14:27:37
// Design Name: 
// Module Name: id
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

//*** ID模块 ***
/*
端口配置：
input：
	rst			复位信号
	pc_i		译码阶段的指令对应的地址
	inst_i		译码阶段的指令
	reg1_data_i	从regfile第一个读端口读出的数据
	reg2_data_i 从regfile第二个读端口读出的数据
output：
	
	reg1_read_o	regfile第一个读端口的使能信号
	reg2_read_o	regfile第二个读端口的使能信号
	reg1_addr_o regfile第一个读端口的地址信号
	reg2_addr_o regfile第二个读端口的地址信号
	
	aluop_o		译码阶段的指令要进行的运算的子类型
	alusel_o	译码阶段的指令要进行的运算的类型
	
	reg1_o		译码阶段的指令要进行的运算的源操作数1
	reg2_o		译码阶段的指令要进行的运算的源操作数2
	
	wd_o		译码阶段的指令要写入的目的寄存器地址
	wreg_o		译码阶段的指令是否有要写入的目的寄存器
*/

module id(
	input wire		rst,
	input wire[`InstAddrBus]	pc_i,
	input wire[`InstBus]		inst_i,
	
	// 读取的regfile的值
	input wire[`RegBus]		reg1_data_i,
	input wire[`RegBus]		reg2_data_i,
	
	// 输出到regfile的信息
	output reg		reg1_read_o,
	output reg		reg2_read_o,
	output reg[`RegAddrBus]	reg1_addr_o,
	output reg[`RegAddrBus] reg2_addr_o,
	
	// 送到执行阶段的信息
	output reg[`AluOpBus]	aluop_o,
	output reg[`AluSelBus]	alusel_o,
	output reg[`RegBus]		reg1_o,
	output reg[`RegBus]		reg2_o,
	output reg[`RegAddrBus]	wd_o,
	output reg				wreg_o
);

// 获取指令的指令码，功能码
wire[5:0] op = inst_i[31:26];
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0];
wire[4:0] op4 = inst_i[20:16];

// 保存指令执行需要的立即数
reg[`RegBus]	imm;

// 指示指令是否有效
reg instvalid;

// 开始对指令进行译码
always @ (*) begin
	if(rst == `RstEnable) begin
		aluop_o		<= `EXE_NOP_OP;
		alusel_o 	<= `EXE_RES_NOP;
		wd_o 		<= `NOPRegAddr;
		wreg_o		<= `WriteDisable;
		instvalid	<= `InstValid;
		reg1_read_o	<= 1'b0;
		reg2_read_o <= 1'b0;
		reg1_addr_o	<= `NOPRegAddr;
		reg2_addr_o <= `NOPRegAddr;
		imm			<= 32'h0;
	end else begin
		aluop_o		<= `EXE_NOP_OP;
		alusel_o	<= `EXE_RES_NOP;
		wd_o		<= inst_i[15:11];
		wreg_o		<= `WriteDisable;
		instvalid	<= `InstInvalid;
		reg1_read_o	<= 1'b0;
		reg2_read_o <= 1'b0;
		reg1_addr_o	<= inst_i[25:21];
		reg2_addr_o <= inst_i[20:16];
		imm			<= `ZeroWord;
		
		case (op)
			// 如果该操作是ori
			`EXE_ORI:	begin
				// 需要将结果存入寄存器
				wreg_o		<= `WriteEnable;
				
				// 运算的子类型是逻辑"或"运算
				aluop_o		<= `EXE_OR_OP;
				
				// 运算类型是逻辑运算
				alusel_o	<= `EXE_RES_LOGIC;
				
				// 需要通过regfile的读端口1读取数据
				reg1_read_o	<= 1'b1;
				
				// 不需要通过regfile的读端口2读取数据
				reg2_read_o	<= 1'b0;
				
				// 指令执行需要的立即数（立即数补齐）
				imm			<= {16'h0, inst_i[15:0]};
				
				// 指令执行要写的母的寄存器地址
				wd_o		<= inst_i[20:16];
				
				// ori指令是有效指令
				instvalid	<= `InstValid;
			end
			
			default:	begin
			end
		endcase 
	end // else
end // always

// 确定第一个进行运算的操作数

always @ (*) begin
	if(rst == `RstEnable) begin
		reg1_o	<= `ZeroWord;
	end else if(reg1_read_o == 1'b1) begin
		reg1_o 	<= reg1_data_i; // 从端口1取值
	end else if(reg1_read_o == 1'b0) begin
		reg1_o	<= imm; // 用立即数当值
	end else begin
		reg1_o  <= `ZeroWord;
	end
end

// 确定第二个进行运算的操作数
always @ (*) begin
	if(rst == `RstEnable) begin
		reg2_o	<= `ZeroWord;
	end else if(reg2_read_o == 1'b1) begin
		reg2_o 	<= reg2_data_i; // 从端口2取值
	end else if(reg2_read_o == 1'b0) begin
		reg2_o	<= imm; // 用立即数当值
	end else begin
		reg2_o  <= `ZeroWord;
	end
end

endmodule
