`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/06 16:02:50
// Design Name: 
// Module Name: sopc
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

module openmips_min_sopc(
	input wire clk,
	input wire rst
);

	// 连接指令器
	wire[`InstAddrBus]	inst_addr;
	wire[`InstBus]		inst;
	wire				rom_ce;
	
	// 链接RAM
	wire[`DataAddrBus]	addr;
	wire[3:0]			sel;
	wire[`DataBus]		data;
	wire				ram_we;
	wire				ram_ce;
	
	wire[`DataBus]		ram_data;
	
	// 例化处理器openmips
	openmips openmips(
		.clk(clk),
		.rst(rst),
		.rom_addr_o(inst_addr),
		.rom_data_i(inst),
		.rom_ce_o(rom_ce),
		
		.ram_data_i(ram_data),
		.ram_addr_o(addr),
		.ram_data_o(data),
		.ram_sel_o(sel),
		.ram_we_o(ram_we),
		.ram_ce_o(ram_ce)
	);
	
	// 例化存储器
	inst_rom inst_rom(
		.ce(rom_ce),
		.addr(inst_addr),
		.inst(inst)
	);
	
	// 例化RAM
	data_ram data_ram(
		.addr(addr),
		.sel(sel),
		.data_i(data),
		.we(ram_we),
		.ce(ram_ce),
		
		.data_o(ram_data)
	);
	
endmodule
