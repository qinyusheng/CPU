// *** PC模块 ***
/* 
端口设置：
input:
	rst 复位信号入口
	clk 时钟信号入口
output:
	pc 读取的指令的地址，第几条指令
	ce 指令存储器使能信号
*/
// 模块思路
/*
	rst复位信号有效时指令存储器禁用，此时pc得到的指令地址为空
	rst指令信号无效时，该模块正常工作
*/

module pc_reg(
	input wire clk,
	input wire rst,
	output reg[`InstAdderBus] pc,
	output reg ce,
);
	// 上升沿触发
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ce <= `ChipDisable;
		end else begin	
			ce <= `ChipEnable;
		end
	end
	
	always @ (posedge clk) begin
		if (ce == `ChipDisable) begin
			pc = <= 32'h00000000
		end else begin
			pc <= pc + 4'h4
		end
	end

endmodule
