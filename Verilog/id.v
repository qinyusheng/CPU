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

//*** IDģ�� ***
/*
�˿����ã�
input��
	rst			��λ�ź�
	pc_i		����׶ε�ָ���Ӧ�ĵ�ַ
	inst_i		����׶ε�ָ��
	reg1_data_i	��regfile��һ�����˿ڶ���������
	reg2_data_i ��regfile�ڶ������˿ڶ���������
	
	�������������������Ҫ
	ex_wreg_i	ִ�н׶�ָ���Ƿ�Ҫд�������
	ex_wdata_i	ִ�н׶�ָ����Ҫд�������
	ex_wd_i		ִ�н׶ε�ָ��д�����ݵĵ�ַ
	
	mem_wreg_i	�ô�׶�ָ���Ƿ�Ҫд�������
	mem_wdata_i	�ô�׶�ָ����Ҫд�������
	mem_wd_i		�ô�׶ε�ָ��д�����ݵĵ�ַ
	
	
output��
	
	reg1_read_o	regfile��һ�����˿ڵ�ʹ���ź�
	reg2_read_o	regfile�ڶ������˿ڵ�ʹ���ź�
	reg1_addr_o regfile��һ�����˿ڵĵ�ַ�ź�
	reg2_addr_o regfile�ڶ������˿ڵĵ�ַ�ź�
	
	aluop_o		����׶ε�ָ��Ҫ���е������������
	alusel_o	����׶ε�ָ��Ҫ���е����������
	
	reg1_o		����׶ε�ָ��Ҫ���е������Դ������1
	reg2_o		����׶ε�ָ��Ҫ���е������Դ������2
	
	wd_o		����׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ
	wreg_o		����׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���
*/

module id(
	input wire		rst,
	input wire[`InstAddrBus]	pc_i,
	input wire[`InstBus]		inst_i,
	
	// ��ȡ��regfile��ֵ
	input wire[`RegBus]		reg1_data_i,
	input wire[`RegBus]		reg2_data_i,
	
	// �����regfile����Ϣ
	output reg		reg1_read_o,
	output reg		reg2_read_o,
	output reg[`RegAddrBus]	reg1_addr_o,
	output reg[`RegAddrBus] reg2_addr_o,
	
	// �͵�ִ�н׶ε���Ϣ
	output reg[`AluOpBus]	aluop_o,
	output reg[`AluSelBus]	alusel_o,
	output reg[`RegBus]		reg1_o,
	output reg[`RegBus]		reg2_o,
	output reg[`RegAddrBus]	wd_o,
	output reg				wreg_o,

	// ����������������
	// ִ�н׶�ָ���������
	input wire				ex_wreg_i,
	input wire[`RegBus]		ex_wdata_i,
	input wire[`RegAddrBus]	ex_wd_i,
	// �ô�׶�ָ��������
	input wire				mem_wreg_i,
	input wire[`RegBus]		mem_wdata_i,
	input wire[`RegAddrBus]	mem_wd_i,
	
	// ��֧��ת
	input wire				is_in_delayslot_i,
	
	output reg				next_inst_in_delayslot_o,
	
	output reg				branch_flag_o,
	output reg[`RegBus]		branch_target_address_o,
	output reg[`RegBus]		link_addr_o,
	output reg				is_in_delayslot_o,
	
	// ϵͳ����
	output reg 				stallreq,
	
	// ������д��
	output wire[`RegBus]		inst_o
);

// inst_o ��������׶ε�ָ��
assign inst_o = inst_i;

// ��ȡָ���ָ���룬������
wire[5:0] op = inst_i[31:26]; // ָ����
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0]; // ������
wire[4:0] op4 = inst_i[20:16];

// ����ָ��ִ����Ҫ��������
reg[`RegBus]	imm;

// ָʾָ���Ƿ���Ч
reg instvalid;

// ��֧��ת����
wire[`RegBus]	pc_plus_8;
wire[`RegBus]	pc_plus_4;

wire[`RegBus]	imm_sll2_signedext;

assign pc_plus_8 = pc_i + 8; // ��ǰ����׶�ָ�����ڶ���ָ��ĵ�ַ
assign pc_plus_4 = pc_i + 4; // ��ǰ����ָ�������ŵ�ָ���ַ

// imm_sll2_signedext ��Ӧ�ķ�ָ֧���е�offset������λ������չ����ʮ��λ���ֵ
assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00 };

// ��ʼ��ָ���������
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
		link_addr_o <= `ZeroWord;
		branch_target_address_o <= `ZeroWord;
		branch_flag_o <= `NotBranch;
		next_inst_in_delayslot_o <= `NotInDelaySlot;
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
		link_addr_o <= `ZeroWord;
		branch_target_address_o <= `ZeroWord;
		branch_flag_o <= `NotBranch;
		next_inst_in_delayslot_o <= `NotInDelaySlot;
		
		case (op)
			`EXE_SPECIAL_INST:	begin
				case (op2)
					5'b00000:	begin
					case (op3)
					// orָ��
					`EXE_OR:	begin
						wreg_o		<= `WriteEnable;
						aluop_o		<= `EXE_OR_OP;
						alusel_o	<= `EXE_RES_LOGIC;
						reg1_read_o	<= 1'b1;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					// andָ��
					`EXE_AND:	begin
						wreg_o		<= `WriteEnable;
						aluop_o		<= `EXE_AND_OP;				
						alusel_o	<= `EXE_RES_LOGIC;
						reg1_read_o	<= 1'b1;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					// XORָ��
					`EXE_XOR:	begin
						wreg_o		<= `WriteEnable;
						aluop_o		<= `EXE_XOR_OP;				
						alusel_o	<= `EXE_RES_LOGIC;
						reg1_read_o	<= 1'b1;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					// NORָ��
					`EXE_NOR:	begin
						wreg_o		<= `WriteEnable;
						aluop_o		<= `EXE_NOR_OP;				
						alusel_o	<= `EXE_RES_LOGIC;
						reg1_read_o	<= 1'b1;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					// sllvָ��
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
					// sravָ��
					`EXE_SRAV:	begin
						wreg_o		<= `WriteEnable;
						aluop_o		<= `EXE_SRA_OP;				
						alusel_o	<= `EXE_RES_SHIFT;
						reg1_read_o	<= 1'b1;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					// syncָ��
					`EXE_SYNC:	begin
						wreg_o		<= `WriteDisable;
						aluop_o		<= `EXE_NOP_OP;				
						alusel_o	<= `EXE_RES_NOP;
						reg1_read_o	<= 1'b0;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					// addָ��
					`EXE_ADD:	begin
						wreg_o		<= `WriteEnable;
						aluop_o		<= `EXE_ADD_OP;
						alusel_o	<= `EXE_RES_ARITHMETIC;
						reg1_read_o	<= 1'b1;
						reg2_read_o	<= 1'b1;
						instvalid	<= `InstValid;
					end
					// subָ��
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
	// oriָ��
	`EXE_ORI:	begin
		wreg_o		<= `WriteEnable;
		aluop_o		<= `EXE_OR_OP;				
		alusel_o	<= `EXE_RES_LOGIC;
		reg1_read_o	<= 1'b1;
		reg2_read_o	<= 1'b0;
		imm 		<= {{16{inst_i[15]}}, inst_i[15:0]};
		wd_o 		<= inst_i[20:16];
		instvalid	<= `InstValid;
	end
	// andiָ��
	`EXE_ANDI:	begin
		wreg_o		<= `WriteEnable;
		aluop_o		<= `EXE_AND_OP;			
		alusel_o	<= `EXE_RES_LOGIC;
		reg1_read_o	<= 1'b1;
		reg2_read_o	<= 1'b0;
		imm 		<= {{16{inst_i[15]}}, inst_i[15:0]};
		wd_o 		<= inst_i[20:16];
		instvalid	<= `InstValid;
	end
	`EXE_XORI:	begin
		wreg_o		<= `WriteEnable;
		aluop_o		<= `EXE_XOR_OP;				
		alusel_o	<= `EXE_RES_LOGIC;
		reg1_read_o	<= 1'b1;
		reg2_read_o	<= 1'b0;
		imm 		<= {{16{inst_i[15]}}, inst_i[15:0]};
		wd_o 		<= inst_i[20:16];
		instvalid	<= `InstValid;
	end
	`EXE_LUI:	begin
		wreg_o		<= `WriteEnable;
		aluop_o		<= `EXE_OR_OP;				
		alusel_o	<= `EXE_RES_LOGIC;
		reg1_read_o	<= 1'b1;
		reg2_read_o	<= 1'b0;
		imm 		<= {{16{inst_i[15]}}, inst_i[15:0]};
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
	// addiuָ��
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
	// ͣ��ָ��
	`EXE_HALT: begin
		wreg_o		<= `WriteEnable;
		aluop_o		<= `EXE_HALT_OP;				
		alusel_o	<= `EXE_RES_CTRL;
		reg1_read_o	<= 1'b0;
		reg2_read_o	<= 1'b0;
		instvalid	<= `InstValid;
	end
	`EXE_SLTI: begin
		wreg_o		<= `WriteEnable;
		aluop_o		<= `EXE_SLTI_OP;				
		alusel_o	<= `EXE_RES_LOGIC;
		reg1_read_o	<= 1'b1;
		reg2_read_o	<= 1'b0;
		imm 		<= {{16{inst_i[15]}}, inst_i[15:0]};
		wd_o 		<= inst_i[20:16];
		instvalid	<= `InstValid;
	end
	`EXE_J: begin	// jָ��
		wreg_o		<= `WriteDisable;
		aluop_o		<= `EXE_J_OP;				
		alusel_o	<= `EXE_RES_JUMP_BRANCH;
		reg1_read_o	<= 1'b0;
		reg2_read_o	<= 1'b0;
		link_addr_o <= `ZeroWord;
		branch_flag_o	<= `Branch;
		next_inst_in_delayslot_o	<= `InDelaySlot;
		instvalid	<= `InstValid;
		branch_target_address_o	<= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
	end
	`EXE_BEQ: begin	// beqָ��
		wreg_o		<= `WriteDisable;
		aluop_o		<= `EXE_BEQ_OP;				
		alusel_o	<= `EXE_RES_JUMP_BRANCH;
		reg1_read_o	<= 1'b1;
		reg2_read_o	<= 1'b1;
		instvalid	<= `InstValid;
		if(reg1_o == reg2_o) begin
			branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			branch_flag_o			<= `Branch;
			next_inst_in_delayslot_o	<= `InDelaySlot;
		end
	end
	`EXE_BNE: begin // bneָ��
		wreg_o		<= `WriteDisable;
		aluop_o		<= `EXE_BNE_OP;		// diff		
		alusel_o	<= `EXE_RES_JUMP_BRANCH;
		reg1_read_o	<= 1'b1;
		reg2_read_o	<= 1'b1;
		instvalid	<= `InstValid;
		if(reg1_o != reg2_o) begin
			branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			branch_flag_o			<= `Branch;
			next_inst_in_delayslot_o	<= `InDelaySlot;
		end
	end

	`EXE_BLTZ: begin	// bltzָ��
		wreg_o		<= `WriteDisable;
		aluop_o		<= `EXE_BLTZ_OP;		// diff		
		alusel_o	<= `EXE_RES_JUMP_BRANCH;
		reg1_read_o	<= 1'b1;
		reg2_read_o	<= 1'b0;
		instvalid	<= `InstValid;
		if(reg1_o[31] == 1'b1) begin
			branch_target_address_o	<= pc_plus_4 + imm_sll2_signedext;
			branch_flag_o			<= `Branch;
			next_inst_in_delayslot_o	<= `InDelaySlot;
		end // if
	end
	
	// ������д�빦��
	`EXE_LW: begin
		wreg_o 		<= `WriteEnable;
		aluop_o 	<= `EXE_LW_OP;
		alusel_o	<= `EXE_RES_LOAD_STORE;
		reg1_read_o <= 1'b1;
		reg2_read_o <= 1'b0;
		wd_o		<= inst_i[20:16];
		instvalid   <= `InstValid;
	end
	
	`EXE_SW: begin
		wreg_o 		<= `WriteDisable;
		aluop_o 	<= `EXE_SW_OP;
		alusel_o	<= `EXE_RES_LOAD_STORE;
		reg1_read_o <= 1'b1;
		reg2_read_o <= 1'b1;
		instvalid   <= `InstValid;
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

// ȷ����һ����������Ĳ�����
always @ (*) begin
	if(rst == `RstEnable) begin
		reg1_o	<= `ZeroWord;
	// �����������������
	end else if((reg1_read_o == 1'b1) 
				&& (ex_wreg_i == 1'b1)
				&& (ex_wd_i == reg1_addr_o)
				) begin
		reg1_o <= ex_wdata_i;
	// �����������������
	end else if((reg1_read_o == 1'b1) 
				&& (mem_wreg_i == 1'b1)
				&& (mem_wd_i == reg1_addr_o)
				) begin
		reg1_o <= mem_wdata_i;
	end else if(reg1_read_o == 1'b1) begin
		reg1_o 	<= reg1_data_i; // �Ӷ˿�1ȡֵ
	end else if(reg1_read_o == 1'b0) begin
		reg1_o	<= imm; // ����������ֵ
	end else begin
		reg1_o  <= `ZeroWord;
	end
end



// ȷ���ڶ�����������Ĳ�����
always @ (*) begin
	if(rst == `RstEnable) begin
		reg2_o	<= `ZeroWord;
	// �����������������
	end else if((reg2_read_o == 1'b1) 
				&& (ex_wreg_i == 1'b1)
				&& (ex_wd_i == reg2_addr_o)
				) begin
		reg2_o <= ex_wdata_i;
	// �����������������
	end else if((reg2_read_o == 1'b1) 
				&& (mem_wreg_i == 1'b1)
				&& (mem_wd_i == reg2_addr_o)
				) begin
		reg2_o <= mem_wdata_i;
	end else if(reg2_read_o == 1'b1) begin
		reg2_o 	<= reg2_data_i; // �Ӷ˿�2ȡֵ
	end else if(reg2_read_o == 1'b0) begin
		reg2_o	<= imm; // ����������ֵ
	end else begin
		reg2_o  <= `ZeroWord;
	end
end

always @ (*) begin
	stallreq <= `NoStop;
end

// �������is_in_delayslot_o��ʾ��ǰָ���Ƿ�λ�ӳٲ�ָ��
always @ (*) begin
	if(rst == `RstEnable) begin
		is_in_delayslot_o <= `NotInDelaySlot;
	end else begin
		// ֱ�ӵ��� is_in_delayslot_i
		is_in_delayslot_o <= is_in_delayslot_i;
	end
end

endmodule
