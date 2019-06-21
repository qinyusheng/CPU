`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/06 15:40:13
// Design Name: 
// Module Name: openmips
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


// �����ļ� OpenMIPS
/*
�˿����ã�
input��
	rst		��λ�ź�
	clk		ʱ���ź�
	rom_data_i	��ָ��洢����ȡ�õ�ָ��
output��
	rom_addr_o	�����ָ��洢���ĵ�ַ
	rom_ce_o	ָ��洢��ʹ���ź�
*/

module openmips(
	input wire		clk,
	input wire 		rst,
	
	input wire[`RegBus]	 rom_data_i,
	
	output wire[`RegBus] rom_addr_o,
	output wire			 rom_ce_o,
	
	input wire[`RegBus]	 ram_data_i,
	output wire[`RegBus] ram_addr_o,
	output wire[`RegBus] ram_data_o,
	output wire			 ram_we_o,
	output wire[3:0]	 ram_sel_o,
	output wire			 ram_ce_o
);

	// ����IF/IDģ��������ģ��ID�ı���
	wire[`InstAddrBus]	pc;
	wire[`InstAddrBus]  id_pc_i;
	wire[`InstBus]		id_inst_i;
	
	// ��������׶�IDģ����ID/EXģ��ı���
	wire[`AluOpBus]		id_aluop_o;
	wire[`AluSelBus]	id_alusel_o;
	wire[`RegBus]		id_reg1_o;
	wire[`RegBus]		id_reg2_o;
	wire 				id_wreg_o;
	wire[`RegAddrBus]	id_wd_o;
	
	// ����ID/EXģ����ִ��ģ��EX�ı���
	wire[`AluOpBus]		ex_aluop_i;
	wire[`AluSelBus]	ex_alusel_i;
	wire[`RegBus]		ex_reg1_i;
	wire[`RegBus]		ex_reg2_i;
	wire 				ex_wreg_i;
	wire[`RegAddrBus]	ex_wd_i;
	
	// ����ִ��ģ��EX��EX/MEMģ��ı���
	wire				ex_wreg_o;
	wire[`RegAddrBus]	ex_wd_o;
	wire[`RegBus]		ex_wdata_o;
	
	// ����EX/MEMģ����ô�׶�MEMģ��ı���
	wire 				mem_wreg_i;
	wire[`RegAddrBus]	mem_wd_i;
	wire[`RegBus]		mem_wdata_i;
	
	// ���ӷô�׶�MEMģ����MEM/WBģ��ı���
	wire				mem_wreg_o;
	wire[`RegAddrBus]	mem_wd_o;
	wire[`RegBus]		mem_wdata_o;
	
	// ����MEM/WBģ�����д�׶�����ı���
	wire 				wb_wreg_i;
	wire[`RegAddrBus]	wb_wd_i;
	wire[`RegBus]		wb_wdata_i;
	
	// ��������ģ��ID��ͨ�üĴ���Regfileģ��ı���
	wire				reg1_read;
	wire				reg2_read;
	wire[`RegBus]		reg1_data;
	wire[`RegBus]		reg2_data;
	wire[`RegAddrBus]	reg1_addr;
	wire[`RegAddrBus]	reg2_addr;
	
	// �����������������
	// id��ex
	wire				id_ex_wreg;
	wire[`RegAddrBus]	id_ex_wd;
	wire[`RegBus]		id_ex_wdata;
	// id��mem
	wire				id_mem_wreg;
	wire[`RegAddrBus]	id_mem_wd;
	wire[`RegBus]		id_mem_wdata;	
	
	// ϵͳ���ƹ���
	wire				stallreq_from_ex;
	wire				stallreq_from_id;
	wire[5:0]			stall;
	
	// ��֧����ת����
	wire[`RegBus]		id_pc_addr;
	wire				id_pc_flag;
	wire 				id_ie_delayslot;
	wire[`RegBus]		id_ie_addr;
	wire				id_ie_next_inst;
	wire				ie_pc_delayslot;
	wire[`RegBus]		ie_ex_addr;
	wire				ie_ex_delayslot;
	wire				ie_id_delayslot;
	
	// ������д�빦��
	wire[`AluOpBus]		ex_aluop_o;
	wire[`RegBus]		ex_reg2_o;
	wire[`RegBus]		ex_addr_o;
	
	wire[`AluOpBus]		mem_aluop;
	wire[`RegBus]		mem_reg2;
	wire[`RegBus]		mem_addr;
	
	wire[`InstBus]		id_inst;
	wire[`InstBus]		ex_inst;
	
	// pc_reg����
	pc_reg pc_reg(
		.clk(clk),
		.rst(rst),
		.pc(pc),
		.ce(rom_ce_o),
		.stall(stall),
		.branch_flag_i(id_pc_flag),
		.branch_target_address_i(id_pc_addr)
	);
	
	assign rom_addr_o = pc; // ָ��洢������ĵ�ַ����pc��ֵ
	
	// IF/ID����
	if_id if_id(
		.clk(clk),
		.rst(rst),
		.if_pc(pc),
		.if_inst(rom_data_i),
		.id_pc(id_pc_i),
		.id_inst(id_inst_i),
		.stall(stall)
	);
	
	// ����׶�IDģ������
	id id(
		.rst(rst),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),
		
		// ����regfileģ�������
		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),
		
		// �͵�regfileģ�����Ϣ
		.reg1_read_o(reg1_read),
		.reg1_addr_o(reg1_addr),
		.reg2_read_o(reg2_read),
		.reg2_addr_o(reg2_addr),
		
		// �͵�ID/EXģ�����Ϣ
		.aluop_o(id_aluop_o),
		.alusel_o(id_alusel_o),
		.reg1_o(id_reg1_o),
		.reg2_o(id_reg2_o),
		.wd_o(id_wd_o),
		.wreg_o(id_wreg_o),
		
		// �����������������
		// ��EX�׶λ�ȡ��Ϣ
		.ex_wreg_i(ex_wreg_o),
		.ex_wd_i(ex_wd_o),
		.ex_wdata_i(ex_wdata_o),
		//��mem�׶λ�ȡ��Ϣ
		.mem_wd_i(mem_wd_o),
		.mem_wreg_i(mem_wreg_o),
		.mem_wdata_i(mem_wdata_o),
		
		// ϵͳ���ƹ���
		.stallreq(stallreq_from_id),
		
		// ��֧����ת����
		.is_in_delayslot_o(id_ie_delayslot),
		.link_addr_o(id_ie_addr),
		.next_inst_in_delayslot_o(id_ie_next_inst),
		.branch_target_address_o(id_pc_addr),
		.branch_flag_o(id_pc_flag),
		
		.is_in_delayslot_i(ie_id_delayslot),
		.inst_o(id_inst)
	);
	
	// ͨ�üĴ���regfileģ������
	regfile regfile(
		.clk(clk),
		.rst(rst),
		.we(wb_wreg_i),
		.waddr(wb_wd_i),
		.wdata(wb_wdata_i),
		.re1(reg1_read),
		.raddr1(reg1_addr),
		.rdata1(reg1_data),
		.re2(reg2_read),
		.raddr2(reg2_addr),
		.rdata2(reg2_data)
	);
	
	// ID/EXģ������
	id_ex id_ex(
		.clk(clk),
		.rst(rst),
		
		// ������׶�IDģ�鴫�ݹ�������Ϣ
		.id_aluop(id_aluop_o),
		.id_alusel(id_alusel_o),
		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_wd(id_wd_o),
		.id_wreg(id_wreg_o),
		
		// ���ݵ�ִ�н׶�EXģ�����Ϣ
		.ex_aluop(ex_aluop_i),
		.ex_alusel(ex_alusel_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i),
		.stall(stall),
		
		// ��֧��תָ��
		.id_is_in_delayslot(id_ie_delayslot),
		.id_link_address(id_ie_addr),
		.next_inst_in_delayslot_i(id_ie_next_inst),
		
		.ex_link_address(ie_ex_addr),
		.ex_is_in_delayslot(ie_ex_delayslot),
		.is_in_delayslot_o(ie_id_delayslot),
		
		.ex_inst(ex_inst)
	);
	
	// EXģ������
	ex ex(
		.rst(rst),
		
		// ��ID/EXģ�鴫�ݹ�������Ϣ
		.aluop_i(ex_aluop_i),
		.alusel_i(ex_alusel_i),
		.reg1_i(ex_reg1_i),
		.reg2_i(ex_reg2_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),
	
		// �����EX/MEMģ�����Ϣ
		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o),
		
		// ϵͳ���ƹ���
		.stallreq(stallreq_from_ex),
		
		// ��֧��ת����
		.link_address_i(ie_ex_addr),
		.is_in_delayslot_i(ie_ex_delayslot),
		
		// ������д�빦��
		.aluop_o(ex_aluop_o),
		.mem_addr_o(ex_addr_o),
		.reg2_o(ex_reg2_o)
		
	);
	
	// EX/MEMģ������
	ex_mem ex_mem(
		.clk(clk),
		.rst(rst),
		
		// ����ִ�н׶�EXģ�����Ϣ
		.ex_wd(ex_wd_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),
		
		// �͵��ô�׶�MEMģ�����Ϣ
		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i),
		.stall(stall),
		
		// ������д�빦��
		.ex_aluop(ex_aluop_o),
		.ex_mem_addr(ex_addr_o),
		.ex_reg2(ex_reg2_o),
		
		.mem_aluop(mem_aluop),
		.mem_mem_addr(mem_addr),
		.mem_reg2(mem_reg2)
	);
	
	// MEMģ������
	mem mem(
		.rst(rst),
		
		// ����EX/MEMģ�����Ϣ
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),
		.wdata_i(mem_wdata_i),
		
		// �͵�MEM/WBģ�����Ϣ
		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o),
		
		// �������ݴ洢������Ϣ
		.mem_data_i(ram_data_i),
		
		// �͵��洢������Ϣ
		.mem_addr_o(ram_addr_o),
		.mem_we_o(ram_we_o),
		.mem_sel_o(ram_sel_o),
		.mem_data_o(ram_data_o),
		.mem_ce_o(ram_ce_o),
		
		// ������д�빦��
		.aluop_i(mem_aluop),
		.mem_addr_i(mem_addr),
		.reg2_i(mem_reg2)
	);
	
	// MEM/WBģ������
	mem_wb mem_wb(
		.clk(clk),
		.rst(rst),
		
		// ���Էô�׶�MEMģ�����Ϣ
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
		
		// �͵���д�׶ε���Ϣ
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i),
		.stall(stall)
	);
	
	// CTRLģ������
	ctrl ctrl(
		.rst(rst),
		.stallreq_from_id(stallreq_from_id),
		.stallreq_from_ex(stallreq_from_ex),
		.stall(stall)
	);
	
endmodule