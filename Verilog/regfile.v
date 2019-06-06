`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/06 14:27:37
// Design Name: 
// Module Name: regfile
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


// Regfile模块
/*
端口设置：
input：
	rst		复位信号
	clk		时钟信号
	waddr	写操作的寄存器地址
	wdata	要写入的数据
	we		写操作的使能信号
	raddr1	读操作的第一个寄存器的地址
	re1		第一个读操作的使能信号
	raddr2	读操作的第二个寄存器的地址
	re2		第二个读操作的使能信号
output：
	rdata1	读出的第一个值
	rdata2	读出的第二个值
*/

module regfile(
	input wire	clk,
	input wire	rst,
	
	// 写端口
	input wire				we,
	input wire[`RegAddrBus]	waddr,
	input wire[`RegBus]		wdata,
	
	// 读端口1
	input wire				re1,
	input wire[`RegAddrBus]	raddr1,
	output reg[`RegBus]	rdata1,
	
	// 读端口2
	input wire 				re2,
	input wire[`RegAddrBus]	raddr2,
	output reg[`RegBus]	rdata2
);

// 定义32个32位的寄存器，用来模拟存储器
reg[`RegBus] regs[0: `RegNum-1];

// 定义写操作

	always @ (posedge clk) begin
		if (rst == `RstDisable) begin
			if ((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
				regs[waddr] <= wdata;
			end
		end
	end
	
// 定义第一个读操作

	always @ (*) begin
		if (rst == `RstEnable) begin
			rdata1 <= `ZeroWord;
		end else if(raddr1 == `RegNumLog2'h0) begin
			rdata1 <= `ZeroWord;
		end else if((raddr1 == waddr) 
					&& (we == `WriteEnable)
					&& (re1 == `ReadEnable)) begin
			rdata1 <= wdata;
		end else if(re1 == `ReadEnable) begin
			rdata1 <= regs[raddr1];
		end else begin
			rdata1 <= `ZeroWord;
		end
	end
	
// 定义第二个读操作
	
	always @ (*) begin
		if (rst == `RstEnable) begin
			rdata2 <= `ZeroWord;
		end else if(raddr2 == `RegNumLog2'h0) begin
			rdata2 <= `ZeroWord;
		end else if((raddr2 == waddr)
					&& (we == `WriteEnable)
					&& (re2 == `ReadEnable)) begin
			rdata2 <= wdata;
		end else if(re2 == `ReadEnable) begin
			rdata2 <= regs[raddr2];
		end else begin
			rdata2 <= `ZeroWord;
		end
	end

endmodule


