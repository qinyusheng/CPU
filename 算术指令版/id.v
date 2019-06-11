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
	
	解决数据相关性问题的需要
	ex_wreg_i	执行阶段指令是否要写入的数据
	ex_wdata_i	执行阶段指令需要写入的数据
	ex_wd_i		执行阶段的指令写入数据的地址
	
	mem_wreg_i	访存阶段指令是否要写入的数据
	mem_wdata_i	访存阶段指令需要写入的数据
	mem_wd_i		访存阶段的指令写入数据的地址
	
	
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
	output reg				wreg_o,

	// 解决数据相关性问题
	// 执行阶段指令的运算结果
	input wire				ex_wreg_i,
	input wire[`RegBus]		ex_wdata_i,
	input wire[`RegAddrBus]	ex_wd_i,
	// 访存阶段指令运算结果
	input wire				mem_wreg_i,
	input wire[`RegBus]		mem_wdata_i,
	input wire[`RegAddrBus]	mem_wd_i
);

// 获取指令的指令码，功能码
wire[5:0] op = inst_i[31:26]; // 指令码
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0]; // 功能码
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
			`EXE_SPECIAL_INST:	begin
				case (op2)
					5'b00000:	begin
					case (op3)
					// or指令
					`EXE_OR:	begin
						wreg_o		<= `WriteEnable;
						aluop_o		<= `EXE_OR_OP;
						alusel_o	<= `EXE_RES_LOGIC;
						reg1_read_o	<= 1'b1;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					// and指令
					`EXE_AND:	begin
						wreg_o		<= `WriteEnable;
						aluop_o		<= `EXE_AND_OP;				
						alusel_o	<= `EXE_RES_LOGIC;
						reg1_read_o	<= 1'b1;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					// XOR指令
					`EXE_XOR:	begin
						wreg_o		<= `WriteEnable;
						aluop_o		<= `EXE_XOR_OP;				
						alusel_o	<= `EXE_RES_LOGIC;
						reg1_read_o	<= 1'b1;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					// NOR指令
					`EXE_NOR:	begin
						wreg_o		<= `WriteEnable;
						aluop_o		<= `EXE_NOR_OP;				
						alusel_o	<= `EXE_RES_LOGIC;
						reg1_read_o	<= 1'b1;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					// sllv指令
					`EXE_SLLV:	begin
						wreg_o		<= `WriteEnable;
						aluop_o		<= `EXE_SLL_OP;				
						alusel_o	<= `EXE_RES_SHIFT;
						reg1_read_o	<= 1'b1;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					`EXE_SRLV:  begin
					    wreg_o		<= `WriteEnable;
						aluop_o		<= `EXE_SRL_OP;				
						alusel_o	<= `EXE_RES_SHIFT;
						reg1_read_o	<= 1'b1;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid; 
					end
					// srav指令
					`EXE_SRAV:	begin
						wreg_o		<= `WriteEnable;
						aluop_o		<= `EXE_SRA_OP;				
						alusel_o	<= `EXE_RES_SHIFT;
						reg1_read_o	<= 1'b1;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					// sync指令
					`EXE_SYNC:	begin
						wreg_o		<= `WriteDisable;
						aluop_o		<= `EXE_NOP_OP;				
						alusel_o	<= `EXE_RES_NOP;
						reg1_read_o	<= 1'b0;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					// add指令
					`EXE_ADD:	begin
						wreg_o		<= `WriteEnable;
						aluop_o		<= `EXE_ADD_OP;
						alusel_o	<= `EXE_RES_ARITHMETIC;
						reg1_read_o	<= 1'b1;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					// sub指令
					`EXE_SUB:	begin
						wreg_o		<= `WriteEnable;
						aluop_o		<= `EXE_SUB_OP;
						alusel_o	<= `EXE_RES_ARITHMETIC;
						reg1_read_o	<= 1'b1;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					default:	begin
					end
				endcase // case op 3
			end 
			default:	begin
			end
		endcase // case op2
	end
	// ori指令
	`EXE_ORI:	begin
		wreg_o		<= `WriteEnable;
		aluop_o		<= `EXE_OR_OP;				
		alusel_o	<= `EXE_RES_LOGIC;
		reg1_read_o	<= 1'b1;
		reg2_read_o	<= 1'b0;
		imm 		<= {16'h0,inst_i[15:0]};
		wd_o 		<= inst_i[20:16];
		instvalid	<= `InstValid;
	end
	// andi指令
	`EXE_ANDI:	begin
		wreg_o		<= `WriteEnable;
		aluop_o		<= `EXE_AND_OP;			
		alusel_o	<= `EXE_RES_LOGIC;
		reg1_read_o	<= 1'b1;
		reg2_read_o	<= 1'b0;
		imm 		<= {16'h0,inst_i[15:0]};
		wd_o 		<= inst_i[20:16];
		instvalid	<= `InstValid;
	end
	`EXE_XORI:	begin
		wreg_o		<= `WriteEnable;
		aluop_o		<= `EXE_XOR_OP;				
		alusel_o	<= `EXE_RES_LOGIC;
		reg1_read_o	<= 1'b1;
		reg2_read_o	<= 1'b0;
		imm 		<= {16'h0,inst_i[15:0]};
		wd_o 		<= inst_i[20:16];
		instvalid	<= `InstValid;
	end
	`EXE_LUI:	begin
		wreg_o		<= `WriteEnable;
		aluop_o		<= `EXE_OR_OP;				
		alusel_o	<= `EXE_RES_LOGIC;
		reg1_read_o	<= 1'b1;
		reg2_read_o	<= 1'b0;
		imm 		<= {inst_i[15:0],16'h0};
		wd_o 		<= inst_i[20:16];
		instvalid	<= `InstValid;
	end
	`EXE_PREF:	begin
		wreg_o		<= `WriteEnable;
		aluop_o		<= `EXE_NOP_OP;				
		alusel_o	<= `EXE_RES_NOP;
		reg1_read_o	<= 1'b0;
		reg2_read_o	<= 1'b0;
		instvalid	<= `InstValid;
	end
	// addiu指令
	`EXE_ADDIU:	begin
		wreg_o		<= `WriteEnable;
		aluop_o		<= `EXE_ADDIU_OP;				
		alusel_o	<= `EXE_RES_ARITHMETIC;
		reg1_read_o	<= 1'b1;
		reg2_read_o	<= 1'b0;
		imm 		<= {{16{inst_i[15]}}, inst_i[15:0]};
		wd_o 		<= inst_i[20:16];
		instvalid	<= `InstValid;
	end
	default:	begin
	end
endcase// case op

if(inst_i[31:21] == 11'b00000000000) begin
	if(op3 == `EXE_SLL) begin
		wreg_o		<= `WriteEnable;
		aluop_o		<= `EXE_SLL_OP;		
		alusel_o	<= `EXE_RES_SHIFT;
		reg1_read_o	<= 1'b0;
		reg2_read_o	<= 1'b1;
		imm[4:0]	<= inst_i[10:6];
		wd_o 		<= inst_i[15:11];
		instvalid	<= `InstValid;
	end else if(op3 == `EXE_SRL) begin
		wreg_o		<= `WriteEnable;
		aluop_o		<= `EXE_SRL_OP;				
		alusel_o	<= `EXE_RES_SHIFT;
		reg1_read_o	<= 1'b0;
		reg2_read_o	<= 1'b1;
		imm[4:0]	<= inst_i[10:6];
		wd_o 		<= inst_i[15:11];
		instvalid	<= `InstValid;
	end else if(op3 == `EXE_SRA) begin
		wreg_o		<= `WriteEnable;
		aluop_o		<= `EXE_SRA_OP;				
		alusel_o	<= `EXE_RES_SHIFT;
		reg1_read_o	<= 1'b0;
		reg2_read_o	<= 1'b1;
		imm[4:0]	<= inst_i[10:6];
		wd_o 		<= inst_i[15:11];
		instvalid	<= `InstValid;
	end
   end
  end // if
 end // always

// 确定第一个进行运算的操作数
always @ (*) begin
	if(rst == `RstEnable) begin
		reg1_o	<= `ZeroWord;
	// 处理数据相关性问题
	end else if((reg1_read_o == 1'b1) 
				&& (ex_wreg_i == 1'b1)
				&& (ex_wd_i == reg1_addr_o)
				) begin
		reg1_o <= ex_wdata_i;
	// 处理数据相关性问题
	end else if((reg1_read_o == 1'b1) 
				&& (mem_wreg_i == 1'b1)
				&& (mem_wd_i == reg1_addr_o)
				) begin
		reg1_o <= mem_wdata_i;
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
	// 处理数据相关性问题
	end else if((reg2_read_o == 1'b1) 
				&& (ex_wreg_i == 1'b1)
				&& (ex_wd_i == reg2_addr_o)
				) begin
		reg2_o <= ex_wdata_i;
	// 处理数据相关性问题
	end else if((reg2_read_o == 1'b1) 
				&& (mem_wreg_i == 1'b1)
				&& (mem_wd_i == reg2_addr_o)
				) begin
		reg2_o <= mem_wdata_i;
	end else if(reg2_read_o == 1'b1) begin
		reg2_o 	<= reg2_data_i; // 从端口2取值
	end else if(reg2_read_o == 1'b0) begin
		reg2_o	<= imm; // 用立即数当值
	end else begin
		reg2_o  <= `ZeroWord;
	end
end


endmodule
