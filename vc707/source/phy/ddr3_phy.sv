//
module ddr3_phy #(
    parameter int  W = 8,  // width of dram interface in bytes.
    parameter int  CL = 16 // cas latency
)(
    // external dram pins
    input               reset_n;
    input  [1:0]        ck_p;
    input  [1:0]        ck_n;
    input  [1:0]        cke;
    input  [1:0]        s_n;
    input               ras_n;
    input               cas_n;
    input               we_n;
    input  [2:0]        ba;
    input  [15:0]       addr;
    input  [1:0]        odt;
    inout  [W-1:0]      dqs_p;
    inout  [W-1:0]      dqs_n;
    inout  [W*8-1:0]    dq;
    inout  [W-1:0]      dm;
    // Internal signals
    input  [8*W*8-1:0]  wdata;
    input  [31:0]       waddr;
    output [8*W*8-1:0]  rdata;
    input  [31:0]       waddr;
    // Training control

);


endmodule

