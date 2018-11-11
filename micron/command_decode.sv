//
module #(
    parameter BYTES = 2,
    parameter DM_BITS = BYTES,
    parameter DQ_BITS = BYTES*8,
    parameter DQS_BITS = BYTES,
    parameter BA_BITS = 3,
    parameter ADDR_BITS = 16
)(
    input   logic   rst_n;
    input   logic   ck;
    input   logic   ck_n;
    input   logic   cke;
    input   logic   cs_n;
    input   logic   ras_n;
    input   logic   cas_n;
    input   logic   we_n;
    inout   logic   [DM_BITS-1:0]   dm_tdqs;
    input   logic   [BA_BITS-1:0]   ba;
    input   logic   [ADDR_BITS-1:0] addr;
    inout   logic   [DQ_BITS-1:0]   dq;
    inout   logic   [DQS_BITS-1:0]  dqs;
    inout   logic   [DQS_BITS-1:0]  dqs_n;
    output  logic   [DQS_BITS-1:0]  tdqs_n;
    input   logic   odt
);

    logic prev_cke;
    always_ff @(posedge ck) prev_cke <= cke;

    typedef enum { MRS, REF, SRE, SRX, PRE, PREA, ACT, WR, WRAP, RD, RDAP, NOP, DES, PDE, PDX, ZQCL, ZQCS, UNK } cmd_type;
    cmd_type cmd;

    casex ({prev_cke, cke, cs_n, ras_n, cas_n, we_n, addr[12], addr[10]})
        6'b110000xx: cmd = MRS;
        6'b110001xx: cmd = REF;
        6'b100001xx: cmd = SRE;
        6'b011xxxxx: cmd = SRX;
        6'b010111xx: cmd = SRX;
        6'b110010x0: cmd = PRE;
        6'b110010x1: cmd = PREA;
        6'b110011xx: cmd = ACT;
        6'b110100x0: cmd = WR;
        6'b110100x1: cmd = WRAP;
        6'b110101x0: cmd = RD;
        6'b110101x1: cmd = RDAP;
        6'b110111xx: cmd = NOP;
        6'b111xxxxx: cmd = DES;
        6'b100111xx: cmd = PDE;
        6'b101xxxxx: cmd = PDE;
        6'b010111xx: cmd = PDX;
        6'b011xxxxx: cmd = PDX;
        6'b110110x1: cmd = ZQCL;
        6'b110110x0: cmd = ZQCS;

        default: cmd = UNK;
    endcase


endmodule;

