`timescale 1ns / 1ps
//changs happens in maindec and inputs and pcsrcD;
//add a wire 'eqneD' to distinguish ben and beq;

module ControlUnit(
	input clk,reset,
	input [5:0]opD,funcD,
	input flushE,equalD,
	output mem2regE,mem2regM,mem2regW,memwriteM,
	output pcsrcD,branchD,eqneD,
	output alusrcE,regdstE,
	output regwriteE,regwriteM,regwriteW,jumpD,jalD,shiftE,jalE,
	output [2:0]alucontrolE,
	
	input [8:0]cn3,
	output reg [31:0]disdata
);

wire [2:0]aluopD;
wire [1:0]cn3t;
assign cn3t = cn3[8:7];

wire mem2regD,memwriteD,alusrcD,regdstD,regwriteD,shiftD;
wire [2:0]alucontrolD;
wire memwriteE;


maindec md(opD,mem2regD,memwriteD,branchD,eqneD,alusrcD,regdstD,regwriteD,jumpD,jalD,aluopD);
aludec  ad(aluopD,funcD,shiftD,alucontrolD);

//assign pcsrcD = branchD & equalD;
assign pcsrcD = (branchD & equalD) ^ (eqneD);

floprc #(10) regE(clk,reset,flushE,
				{mem2regD,memwriteD,shiftD,alusrcD,regdstD,regwriteD,alucontrolD,jalD},
				{mem2regE,memwriteE,shiftE,alusrcE,regdstE,regwriteE,alucontrolE,jalE}
				);

flopr #(3) regM(clk,reset,
				{mem2regE,memwriteE,regwriteE},
				{mem2regM,memwriteM,regwriteM}
				);

flopr #(2) regW(clk,reset,
				{mem2regM,regwriteM},
				{mem2regW,regwriteW}
				);


always @(*)
    case(cn3t)
    2'b00: disdata = { {3'b000, mem2regE }, {3'b000, mem2regM },{3'b000, mem2regW }, {3'b000, branchD },  {3'b000, regwriteE }, {3'b000, regwriteM },{3'b000, regwriteW }, {1'b0, regdstE }};
    2'b01: disdata = { {4'b0000}, {4'b0000}, { 4{opD[5]} }, { 4{opD[4]} }, { 4{opD[3]} }, { 4{opD[2]} }, { 4{opD[1]} }, { 4{opD[0]} } };
    2'b10: disdata = { {4'b0000}, {4'b0000}, { 4{funcD[5]} }, { 4{funcD[4]} }, { 4{funcD[3]} }, { 4{funcD[2]} }, { 4{funcD[1]} }, { 4{funcD[0]} } };
    2'b11: disdata = { 8{1'b0, aluopD } };
    default: disdata = { {3'b000, mem2regE }, {3'b000, mem2regM },{3'b000, mem2regW }, {3'b000, branchD },  {3'b000, regwriteE }, {3'b000, regwriteM },{3'b000, regwriteW }, {1'b0, regdstE }};
    endcase


endmodule