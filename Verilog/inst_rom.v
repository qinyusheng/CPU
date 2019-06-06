`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/06 14:27:37
// Design Name: 
// Module Name: inst_rom
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


// 指令存储器
/*
端口设置:
input:
	ce			使能信号
	addr		要读取的指令地址
output:
	inst		读出的指令
*/

module inst_rom(
	input wire		ce,
	input wire[`InstAddrBus]	addr,
	output reg[`InstBus]		inst
);
	
	// 定义一个数组，大小是InstMemNum，元素宽度为InstBus
	reg[`InstBus]		inst_mem[0 : `InstMemNum-1];
	
	// 从文件inst_rom.data中读取指令
	initial $readmemh ("inst_rom.data", inst_mem);
	
	// 当复位信号无效时，依据输入地址，给出对应的元素
	always @ (*) begin
		if(ce == `ChipDisable) begin
			inst <= `ZeroWord;
		end else begin
			inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
		end
	end
endmodule
