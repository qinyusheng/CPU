`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/07 11:59:21
// Design Name: 
// Module Name: openmips_min_sopc_tb
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


module openmips_min_sopc_tb();
    reg clk;
    reg rst;
    
    // ����ʱ���źţ�����20ns
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    
    // 195ns�󣬸�λ�ź���Ч
    // ����1000ns����ͣ����
    initial begin
        rst = `RstEnable;
        #195 rst = `RstDisable;
        #1000 $stop;
    end
    
    // ������Сsopc
    openmips_min_sopc sopc(
        .clk(clk),
        .rst(rst)
    );
endmodule
