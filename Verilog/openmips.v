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


// 顶层文件 OpenMIPS
/*
端口配置：
input：
	rst		复位信号
	clk		时钟信号
	rom_data_i	从指令存储器中取得的指令
output：
	rom_addr_o	输出到指令存储器的地址
	rom_ce_o	指令存储器使能信号
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

	// 连接IF/ID模块与译码模块ID的变量
	wire[`InstAddrBus]	pc;
	wire[`InstAddrBus]  id_pc_i;
	wire[`InstBus]		id_inst_i;
	
	// 连接译码阶段ID模块与ID/EX模块的变量
	wire[`AluOpBus]		id_aluop_o;
	wire[`AluSelBus]	id_alusel_o;
	wire[`RegBus]		id_reg1_o;
	wire[`RegBus]		id_reg2_o;
	wire 				id_wreg_o;
	wire[`RegAddrBus]	id_wd_o;
	
	// 连接ID/EX模块与执行模块EX的变量
	wire[`AluOpBus]		ex_aluop_i;
	wire[`AluSelBus]	ex_alusel_i;
	wire[`RegBus]		ex_reg1_i;
	wire[`RegBus]		ex_reg2_i;
	wire 				ex_wreg_i;
	wire[`RegAddrBus]	ex_wd_i;
	
	// 连接执行模块EX与EX/MEM模块的变量
	wire				ex_wreg_o;
	wire[`RegAddrBus]	ex_wd_o;
	wire[`RegBus]		ex_wdata_o;
	
	// 连接EX/MEM模块与访存阶段MEM模块的变量
	wire 				mem_wreg_i;
	wire[`RegAddrBus]	mem_wd_i;
	wire[`RegBus]		mem_wdata_i;
	
	// 连接访存阶段MEM模块与MEM/WB模块的变量
	wire				mem_wreg_o;
	wire[`RegAddrBus]	mem_wd_o;
	wire[`RegBus]		mem_wdata_o;
	
	// 连接MEM/WB模块与回写阶段输入的变量
	wire 				wb_wreg_i;
	wire[`RegAddrBus]	wb_wd_i;
	wire[`RegBus]		wb_wdata_i;
	
	// 连接译码模块ID与通用寄存器Regfile模块的变量
	wire				reg1_read;
	wire				reg2_read;
	wire[`RegBus]		reg1_data;
	wire[`RegBus]		reg2_data;
	wire[`RegAddrBus]	reg1_addr;
	wire[`RegAddrBus]	reg2_addr;
	
	// 处理数据相关性问题
	// id与ex
	wire				id_ex_wreg;
	wire[`RegAddrBus]	id_ex_wd;
	wire[`RegBus]		id_ex_wdata;
	// id与mem
	wire				id_mem_wreg;
	wire[`RegAddrBus]	id_mem_wd;
	wire[`RegBus]		id_mem_wdata;	
	
	// 系统控制功能
	wire				stallreq_from_ex;
	wire				stallreq_from_id;
	wire[5:0]			stall;
	
	// 分支与跳转功能
	wire[`RegBus]		id_pc_addr;
	wire				id_pc_flag;
	wire 				id_ie_delayslot;
	wire[`RegBus]		id_ie_addr;
	wire				id_ie_next_inst;
	wire				ie_pc_delayslot;
	wire[`RegBus]		ie_ex_addr;
	wire				ie_ex_delayslot;
	wire				ie_id_delayslot;
	
	// 加载与写入功能
	wire[`AluOpBus]		ex_aluop_o;
	wire[`RegBus]		ex_reg2_o;
	wire[`RegBus]		ex_addr_o;
	
	wire[`AluOpBus]		mem_aluop;
	wire[`RegBus]		mem_reg2;
	wire[`RegBus]		mem_addr;
	
	wire[`InstBus]		id_inst;
	wire[`InstBus]		ex_inst;
	
	// pc_reg例化
	pc_reg pc_reg(
		.clk(clk),
		.rst(rst),
		.pc(pc),
		.ce(rom_ce_o),
		.stall(stall),
		.branch_flag_i(id_pc_flag),
		.branch_target_address_i(id_pc_addr)
	);
	
	assign rom_addr_o = pc; // 指令存储器输入的地址就是pc的值
	
	// IF/ID例化
	if_id if_id(
		.clk(clk),
		.rst(rst),
		.if_pc(pc),
		.if_inst(rom_data_i),
		.id_pc(id_pc_i),
		.id_inst(id_inst_i),
		.stall(stall)
	);
	
	// 译码阶段ID模块例化
	id id(
		.rst(rst),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),
		
		// 来自regfile模块的输入
		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),
		
		// 送到regfile模块的信息
		.reg1_read_o(reg1_read),
		.reg1_addr_o(reg1_addr),
		.reg2_read_o(reg2_read),
		.reg2_addr_o(reg2_addr),
		
		// 送到ID/EX模块的信息
		.aluop_o(id_aluop_o),
		.alusel_o(id_alusel_o),
		.reg1_o(id_reg1_o),
		.reg2_o(id_reg2_o),
		.wd_o(id_wd_o),
		.wreg_o(id_wreg_o),
		
		// 处理数据相关性问题
		// 从EX阶段获取信息
		.ex_wreg_i(ex_wreg_o),
		.ex_wd_i(ex_wd_o),
		.ex_wdata_i(ex_wdata_o),
		//从mem阶段获取信息
		.mem_wd_i(mem_wd_o),
		.mem_wreg_i(mem_wreg_o),
		.mem_wdata_i(mem_wdata_o),
		
		// 系统控制功能
		.stallreq(stallreq_from_id),
		
		// 分支和跳转功能
		.is_in_delayslot_o(id_ie_delayslot),
		.link_addr_o(id_ie_addr),
		.next_inst_in_delayslot_o(id_ie_next_inst),
		.branch_target_address_o(id_pc_addr),
		.branch_flag_o(id_pc_flag),
		
		.is_in_delayslot_i(ie_id_delayslot),
		.inst_o(id_inst)
	);
	
	// 通用寄存器regfile模块例化
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
	
	// ID/EX模块例化
	id_ex id_ex(
		.clk(clk),
		.rst(rst),
		
		// 从译码阶段ID模块传递过来的信息
		.id_aluop(id_aluop_o),
		.id_alusel(id_alusel_o),
		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_wd(id_wd_o),
		.id_wreg(id_wreg_o),
		
		// 传递到执行阶段EX模块的信息
		.ex_aluop(ex_aluop_i),
		.ex_alusel(ex_alusel_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i),
		.stall(stall),
		
		// 分支跳转指令
		.id_is_in_delayslot(id_ie_delayslot),
		.id_link_address(id_ie_addr),
		.next_inst_in_delayslot_i(id_ie_next_inst),
		
		.ex_link_address(ie_ex_addr),
		.ex_is_in_delayslot(ie_ex_delayslot),
		.is_in_delayslot_o(ie_id_delayslot),
		
		.ex_inst(ex_inst)
	);
	
	// EX模块例化
	ex ex(
		.rst(rst),
		
		// 从ID/EX模块传递过来的信息
		.aluop_i(ex_aluop_i),
		.alusel_i(ex_alusel_i),
		.reg1_i(ex_reg1_i),
		.reg2_i(ex_reg2_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),
	
		// 输出到EX/MEM模块的信息
		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o),
		
		// 系统控制功能
		.stallreq(stallreq_from_ex),
		
		// 分支跳转功能
		.link_address_i(ie_ex_addr),
		.is_in_delayslot_i(ie_ex_delayslot),
		
		// 加载与写入功能
		.aluop_o(ex_aluop_o),
		.mem_addr_o(ex_addr_o),
		.reg2_o(ex_reg2_o)
		
	);
	
	// EX/MEM模块例化
	ex_mem ex_mem(
		.clk(clk),
		.rst(rst),
		
		// 来自执行阶段EX模块的信息
		.ex_wd(ex_wd_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),
		
		// 送到访存阶段MEM模块的信息
		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i),
		.stall(stall),
		
		// 加载与写入功能
		.ex_aluop(ex_aluop_o),
		.ex_mem_addr(ex_addr_o),
		.ex_reg2(ex_reg2_o),
		
		.mem_aluop(mem_aluop),
		.mem_mem_addr(mem_addr),
		.mem_reg2(mem_reg2)
	);
	
	// MEM模块例化
	mem mem(
		.rst(rst),
		
		// 来自EX/MEM模块的信息
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),
		.wdata_i(mem_wdata_i),
		
		// 送到MEM/WB模块的信息
		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o),
		
		// 来自数据存储器的信息
		.mem_data_i(ram_data_i),
		
		// 送到存储器的信息
		.mem_addr_o(ram_addr_o),
		.mem_we_o(ram_we_o),
		.mem_sel_o(ram_sel_o),
		.mem_data_o(ram_data_o),
		.mem_ce_o(ram_ce_o),
		
		// 加载与写入功能
		.aluop_i(mem_aluop),
		.mem_addr_i(mem_addr),
		.reg2_i(mem_reg2)
	);
	
	// MEM/WB模块例化
	mem_wb mem_wb(
		.clk(clk),
		.rst(rst),
		
		// 来自访存阶段MEM模块的信息
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
		
		// 送到回写阶段的信息
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i),
		.stall(stall)
	);
	
	// CTRL模块例化
	ctrl ctrl(
		.rst(rst),
		.stallreq_from_id(stallreq_from_id),
		.stallreq_from_ex(stallreq_from_ex),
		.stall(stall)
	);
	
endmodule