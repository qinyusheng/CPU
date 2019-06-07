module openmips_min_sopc(
	input wire clk,
	input wire rst
);

	// 连接指令器
	wire[`InstAddrBus]	inst_addr;
	wire[`InstBus]		inst;
	wire				rom_ce;
	
	// 例化处理器openmips
	openmips openmips(
		.clk(clk),
		.rst(rst),
		.rom_addr_o(inst_addr),
		.rom_data_i(inst),
		.rom_ce_o(rom_ce)
	);
	
	// 例化存储器
	inst_rom inst_rom(
		.ce(rom_ce),
		.addr(inst_addr),
		.inst(inst)
	);
	
endmodule