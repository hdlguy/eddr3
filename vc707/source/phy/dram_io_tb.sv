
module dram_io_tb();

    localparam W = 8;
    
    // external dram pins
    logic               reset_n;
    logic  [1:0]        ck_p;
    logic  [1:0]        ck_n;
    logic  [1:0]        cke;
    logic  [1:0]        s_n;
    logic               ras_n;
    logic               cas_n;
    logic               we_n;
    logic  [2:0]        ba;
    logic  [15:0]       addr;
    logic  [1:0]        odt;
    logic  [W-1:0]      dqs_p;
    logic  [W-1:0]      dqs_n;
    logic  [W*8-1:0]    dq;
    logic  [W-1:0]      dm;
    // Internal signals
    logic               reset; // synchronouse to dclk.
    logic               refclk;
    logic               hsclk; // serdes ddr clock
    logic               dclk;  // clock for input data to serdes.

    dram_io #(.W(W))uut (
        .reset_n(reset_n),
        .ck_p(ck_p),
        .ck_n(ck_n),
        .cke(cke),
        .s_n(s_n),
        .ras_n(ras_n),
        .cas_n(cas_n),
        .we_n(we_n),
        .ba(ba),
        .addr(addr),
        .odt(odt),
//        .dqs_p(dqs_p),
//        .dqs_n(dqs_n),
//        .dq(dq),
        .dm(dm),
        .reset(reset),
        .refclk(refclk),
        .hsclk(hsclk),
        .dclk(dclk)
    );

    localparam dclk_period = 8;
    initial forever begin
        dclk = 0;
        hsclk = 1;
        #(dclk_period/8);
        dclk = 0;
        hsclk = 0;
        #(dclk_period/8);
        dclk = 0;
        hsclk = 1;
        #(dclk_period/8);
        dclk = 0;
        hsclk = 0;
        #(dclk_period/8);
        dclk = 1;
        hsclk = 1;
        #(dclk_period/8);
        dclk = 1;
        hsclk = 0;
        #(dclk_period/8);
        dclk = 1;
        hsclk = 1;
        #(dclk_period/8);
        dclk = 1;
        hsclk = 0;
        #(dclk_period/8);
    end
    
    initial begin
        reset = 1;
        #(dclk_period*10);
        reset = 0;
    end

endmodule
