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
module ex{
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
};

//逻辑运算最后的结果
reg[`RegBus] logicout;

//依据aluop_i所指示的运算的子类型进行计算
always @ (*) begin
	if (rst == `RstEnable) begin
		logicout <= `Zeroword;
	end else begin
		case(aluop_i)
		`EXE_OR_OP:begin
			logicout <= reg1_i | reg2_i;
		end
		default: begin
			logicout <= `Zeroword;
		end
	endcase
	end//if
end//always

//依据alusel_i所指示的运算的类型，选择一个运算结果作为最终的结果
always @ (*) begin
	wd_o <= wd_i;
	wreg_o <= wreg_i;
	case(alusel_i)
		`EXE_RES_LOGIC:
			wdata_o <= logicout;
		end
		default: begin
			wdata_o <= `Zeroword;
		end
	endcase
end//always

endmodule


			`