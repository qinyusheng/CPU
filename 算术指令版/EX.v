`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/06 14:27:37
// Design Name: 
// Module Name: ex
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


//执行模块
//rst 复位信号
//aluop_i 执行阶段要进行运算的子类型(输入)
//alusel_i 执行阶段要进行运算类型(输入)
//reg1_i 参与运算的源操作数1(输入)
//reg2_i 参与运算的源操作数2(输入)
//wd_i 指令执行要写入的目的寄存器地址(输入)
//wreg_i 是否有要写入的目的寄存器(输入)
//wd_o 执行阶段最终要写入的目的寄存器地址(输出)
//wreg_o 执行阶段是否要写入目的寄存器(输出)
//wdata_o  执行阶段写入目的寄存器的值(输出)
module ex(
	input wire  rst,
	
	//译码阶段送到执行模块的信息
	input wire[`AluOpBus] aluop_i,
	input wire[`AluSelBus] alusel_i,
	input wire[`RegBus] reg1_i,
	input wire[`RegBus] reg2_i,
	input wire[`RegAddrBus] wd_i,
	input wire wreg_i,
	
	//执行模块执行得出的结果
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus] wdata_o
);

//逻辑运算最后的结果
reg[`RegBus]	logicout; // 逻辑运算结果
reg[`RegBus]	shiftres; // 移位运算结果
reg[`RegBus]	arithmeticres; // 保存算数运算结果
wire[`RegBus]	reg2_i_mux;
wire[`RegBus]	result_sum;
wire			reg1_eq_reg2; // 两个操作数是否相等

// 如果是减法运算取补码
assign reg2_i_mux = (aluop_i == `EXE_SUB_OP)? (~reg2_i)+1 : reg2_i;
// 求出加法/减法运算结果
assign result_sum = reg1_i + reg2_i_mux;
assign 

//依据aluop_i所指示的运算的子类型进行逻辑运算
always @ (*) begin
	if (rst == `RstEnable) begin
		logicout <= `ZeroWord;
	end else begin
		case(aluop_i)
		`EXE_OR_OP:begin
			logicout <= reg1_i | reg2_i;
		end
		`EXE_AND_OP:begin
			logicout <= reg1_i & reg2_i;
		end
		`EXE_NOR_OP:begin
			logicout <= ~(reg1_i | reg2_i);
		end
		`EXE_XOR_OP:begin
			logicout <= reg1_i ^ reg2_i;
		end
		default: begin
			logicout <= `ZeroWord;
		end
	endcase
	end//if
end//always

// 进行移位运算
always @ (*) begin
	if (rst == `RstEnable) begin
		shiftres <= `ZeroWord;
	end else begin
		case(aluop_i)
		`EXE_SLL_OP:begin
			shiftres <= reg2_i << reg1_i[4:0];
		end
		`EXE_SRL_OP:begin
			shiftres <= reg2_i >> reg1_i[4:0];
		end
		`EXE_SRA_OP:begin
			shiftres <= ({32{reg2_i[31]}} << (6'd32-{1'b0 , reg1_i[4:0]}))
			             | reg2_i >> reg1_i[4:0];
		end
		default: begin
			logicout <= `ZeroWord;
		end
	endcase
	end //if
end //always

// 进行算术运算
always @ (*) begin
	if(rst == `RstEnable) begin
		arithmeticres <= `ZeroWord;
	end else begin
		case (aluop_i)
			`EXE_ADD_OP, `EXE_ADDIU_OP: begin
				arithmeticres <= result_sum;
			end
			`EXE_SUB_OP: begin
				arithmeticres <= result_sum;
			end

//依据alusel_i所指示的运算的类型，选择一个运算结果作为最终的结果
always @ (*) begin
	wd_o <= wd_i;
	wreg_o <= wreg_i;
	case(alusel_i)
		`EXE_RES_LOGIC: begin
			wdata_o <= logicout;
		end
		`EXE_RES_SHIFT: begin
			wdata_o <= shiftres;
		end
		`EXE_RES_ARITHMETIC: begin
			wdata_o <= arithmeticres;
		end
		default: begin
			wdata_o <= `ZeroWord;
		end
	endcase
end//always



endmodule
