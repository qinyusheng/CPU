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


//ִ��ģ��
//rst ��λ�ź�
//aluop_i ִ�н׶�Ҫ���������������(����)
//alusel_i ִ�н׶�Ҫ������������(����)
//reg1_i ���������Դ������1(����)
//reg2_i ���������Դ������2(����)
//wd_i ָ��ִ��Ҫд���Ŀ�ļĴ�����ַ(����)
//wreg_i �Ƿ���Ҫд���Ŀ�ļĴ���(����)
//wd_o ִ�н׶�����Ҫд���Ŀ�ļĴ�����ַ(���)
//wreg_o ִ�н׶��Ƿ�Ҫд��Ŀ�ļĴ���(���)
//wdata_o  ִ�н׶�д��Ŀ�ļĴ�����ֵ(���)

module ex(
	input wire  rst,
	
	//����׶��͵�ִ��ģ�����Ϣ
	input wire[`AluOpBus] aluop_i,
	input wire[`AluSelBus] alusel_i,
	input wire[`RegBus] reg1_i,
	input wire[`RegBus] reg2_i,
	input wire[`RegAddrBus] wd_i,
	input wire wreg_i,
	
	//ִ��ģ��ִ�еó��Ľ��
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus] wdata_o,
	
	// ϵͳ���ƹ���
	output reg			stallreq,
	
	// ��֧����ת����
	input wire[`RegBus]	link_address_i, // ִ�н׶�ת��ָ��Ҫ����ķ��ص�ַ
	input wire			is_in_delayslot_i, // ��ǰִ�н׶ε�ָ���Ƿ�λ���ӳٲ�
	
	// ������д��
	input wire[`RegBus] inst_i,
	
	output wire[`AluOpBus]	aluop_o,
	output wire[`RegBus]	mem_addr_o,
	output wire[`RegBus] 	reg2_o
);

//�߼��������Ľ��
reg[`RegBus]	logicout; // �߼�������
reg[`RegBus]	shiftres; // ��λ������
reg[`RegBus]	arithmeticres; // ��������������
wire[`RegBus]	reg2_i_mux;
wire[`RegBus]	result_sum;
wire			reg1_eq_reg2; // �����������Ƿ����

// ����Ǽ�������ȡ����
assign reg2_i_mux = (aluop_i == `EXE_SUB_OP || aluop_i == `EXE_SLTI_OP)? (~reg2_i)+1 : reg2_i;
// ����ӷ�/����������
assign result_sum = reg1_i + reg2_i_mux;

// ������д��
assign aluop_o 		= aluop_i;
assign mem_addr_o 	= reg1_i + {{16{inst_i[15]}}, inst_i[15:0]}; // ����洢��ַ
assign reg2_o		= reg2_i;

//����aluop_i��ָʾ������������ͽ����߼�����
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
		`EXE_SLTI_OP:begin
			logicout <= {31'h0,result_sum[31]};
		end
		default: begin
			logicout <= `ZeroWord;
		end
	endcase
	end//if
end//always

// ������λ����
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
			shiftres <= `ZeroWord;
		end
	endcase
	end //if
end //always

// ������������
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
			default: begin
				arithmeticres <= `ZeroWord;
			end
		endcase
	end
end

//����alusel_i��ָʾ����������ͣ�ѡ��һ����������Ϊ���յĽ��
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
		`EXE_RES_JUMP_BRANCH: begin
			wdata_o <= link_address_i;
		end
		default: begin
			wdata_o <= `ZeroWord;
		end
	endcase
end//always

// ִ��ϵͳ���ƹ���
always @ (*) begin
	if(alusel_i == `EXE_RES_CTRL) begin
		case(aluop_i) 
			`EXE_HALT_OP: begin
				stallreq <= `Stop;
			end
			default: begin
				stallreq <= `NoStop;
			end
		endcase 
	end else begin
		stallreq <= `NoStop;
	end
end

endmodule
