// This module contains the ddr3 dram phy.
module dram_phy #(
    parameter int  W = 2  // width of dram interface in bytes.
)(
    // external dram pins
    output logic            reset_n,
    output logic [1:0]      ck_p,
    output logic [1:0]      ck_n,
    output logic [1:0]      cke,
    output logic [1:0]      s_n,
    output logic            ras_n,
    output logic            cas_n,
    output logic            we_n,
    output logic [2:0]      ba,
    output logic [15:0]     addr,
    output logic [1:0]      odt,
    inout  logic [W-1:0]    dqs_p,
    inout  logic [W-1:0]    dqs_n,
    inout  logic [W*8-1:0]  dq,
    output logic [W-1:0]    dm,
    // control and calibration
    input  logic            reset,   // synchronouse to dclk.
    input  logic            clkin,   // reference clock to PHY PLL.
    input  logic            calclk,  // clock to control io delays, etc, for calibration.
    // command and data interface
    output logic            divclk,  // command and data clock.
);

    localparam int DELGRP = 0;

    // make the clocks
    logic hsclk_90, hsclk, pll_locked;
    clock_gen clock_gen_inst (.reset(reset), .clkin(clkin), .hsclk_90(hsclk_90), .hsclk(hsclk), .divclk(divclk), .locked(pll_locked));

    // dram io logic.

endmodule

