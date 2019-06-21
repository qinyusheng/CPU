`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/06 14:27:37
// Design Name: 
// Module Name: defines
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

// 定义全局变量,
`define RstEnable	1'b1 
`define RstDisable	1'b0
`define ZeroWord	32'h00000000
`define WriteEnable	 1'b1
`define WriteDisable	1'b0
`define ReadEnable	1'b1
`define ReadDisable	 1'b0
`define AluOpBus	7:0
`define AluSelBus	2:0
`define InstValid	1'b0
`define InstInvalid	 1'b1
`define True_v		1'b1
`define False_v		1'b0
`define ChipEnable 	 1'b1
`define ChipDisable	  1'b0

// 与指令相关的宏

`define EXE_ORI		6'b001101
`define EXE_NOP		6'b000000
`define EXE_AND		6'b100100
`define EXE_OR		6'b100101
`define	 EXE_XOR		6'b100110
`define	 EXE_NOR		6'b100111
`define	 EXE_ANDI	6'b001100
`define	 EXE_XORI	6'b001110
`define EXE_LUI		6'b001111

`define EXE_ADD		6'b100000
`define	 EXE_SUB		6'b100010
`define EXE_ADDIU	6'b001001

`define EXE_MULT	6'b011000
`define	 EXE_MULTU	6'b011001
`define	 EXE_MUL		6'b000010

`define EXE_SLL		6'b000000
`define EXE_SLLV	6'b000100
`define EXE_SRL		6'b000010
`define EXE_SRLV	6'b000110
`define EXE_SRA		6'b000011
`define EXE_SRAV 	6'b000111

`define	 EXE_SYNC	6'b001111
`define EXE_PREF	6'b110011
`define EXE_SPECIAL_INST	6'b000000 // special类的指令码

`define EXE_REGIMM_INST		6'b000001
`define EXE_SPECIAL2_INST	6'b011100

`define EXE_HALT	6'b111111 // 停机
`define EXE_SLTI	6'b011100

// 分支跳转指令
`define EXE_J		6'b111000
`define EXE_BEQ		6'b110000
`define	 EXE_BNE	6'b110001
`define EXE_BLTZ	6'b110010

`define EXE_J_OP	8'b00111000
`define	 EXE_BEQ_OP	8'b00110000
`define EXE_BNE_OP	8'b00110001
`define EXE_BLTZ_OP 8'b00110010

// 加载与写入
`define EXE_SW 		6'b101011
`define EXE_LW 		6'b100011

`define EXE_SW_OP 	8'b00101011
`define EXE_LW_OP 	8'b00100011

// Aluop
`define EXE_OR_OP	8'b00100101
`define EXE_AND_OP  8'b00100100
`define EXE_XOR_OP  8'b00100110
`define EXE_NOR_OP	8'b00100111
`define EXE_SLL_OP	8'b11000000
`define EXE_SRL_OP	8'b00000010
`define EXE_SRA_OP	8'b00000011
`define EXE_NOP_OP	8'b00000000

`define EXE_ADD_OP	8'b00100000
`define	 EXE_SUB_OP	8'b00100010
`define EXE_ADDIU_OP 8'b00001001

// 系统控制
`define EXE_HALT_OP	 8'b00111111 // 停机

// 比较
`define EXE_SLTI_OP	8'b00011100

// AluSel
`define EXE_RES_LOGIC	3'b001
`define EXE_RES_NOP		3'b000
`define EXE_RES_SHIFT	3'b010
`define EXE_RES_ARITHMETIC	3'b011
`define EXE_RES_CTRL	3'b100
`define EXE_RES_JUMP_BRANCH	3'b101
`define EXE_RES_LOAD_STORE 3'b110

// ROM相关的宏定义
`define InstAddrBus	 31:0// 地址总线宽度
`define InstBus		31:0//数据总线宽度
`define InstMemNum	131071
`define InstMemNumLog2	17

// 通用寄存器相关
`define RegAddrBus	4:0
`define RegBus		31:0
`define RegWidth	32
`define DoubleRegWidth	64
`define DoubleRegBus	63:0
`define RegNum		32
`define RegNumLog2	5
`define NOPRegAddr	5'b00000

// 系统控制相关
`define Stop		1'b1
`define NoStop		1'b0

// 分支与跳转功能相关
`define Branch		1'b1 // 转移
`define	 NotBranch	1'b0 // 不转移

`define InDelaySlot		1'b1 // 在延迟槽中
`define NotInDelaySlot	1'b0 // 不在延迟槽中

// 加载与写入功能
`define DataAddrBus		31:0
`define DataBus			31:0
`define DataMemNum		128
`define DataMemNumLog2	17
`define ByteWidth		7:0
