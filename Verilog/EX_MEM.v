//EX/MEM模块：将从执行阶段取得的运算结果在下一个时钟传递到流水线的访存阶段
//接口信息
//复位信号（输入）	rst
//时钟信号（输入）	clk
//执行阶段的指令执行后要写入的寄存器的地址（输入）	ex_wd
//执行阶段的指令执行后是否有要写入的寄存器（输入）	ex_wreg 
//执行阶段的指令执行后要写入的寄存器的值（输入）	ex_wdata
//访存阶段要写入的寄存器的地址（输出）	mem_wd
//访存阶段是否要写入目的寄存器（输出）	mem_wreg
//访存阶段的指令要写入的目的寄存器的值（输出） mem_wdata

module ex_mem{
	//时钟信号和复位信号
	input wire clk,
	input wire rst,
	//来自于执行阶段的信息
	input wire[`RegAddrBus] ex_wd,
	input wire ex_wreg,
	input wire[`RegBus] ex_wdata,
	//要送达到访存阶段的信息
	output reg[`RegAddrBus] mem_wd,
	output reg mem_wreg,
	output reg[`RegBus] mem_wdata
};

always @ (posedge clk) begin
	if(rst==`RstEnable) begin
		mem_wd <= `NoPReAddr;
		mem_wreg <= `WriteDisable;
		mem_data <= `Zeroword;
	end else begin
		mem_wd <= ex_wd;
		mem_wreg <= ex_wreg;
		mem_data <= ex_wdata;
	end
end//always

endmodule
