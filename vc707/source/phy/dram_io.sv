// This module contains just the io logic of the ddr3 phy.
module dram_io #(
    parameter int  W = 2  // width of dram interface in bytes.
)(
    // external dram pins
    output logic              reset_n,
    output logic [1:0]        ck_p,
    output logic [1:0]        ck_n,
    output logic [1:0]        cke,
    output logic [1:0]        s_n,
    output logic              ras_n,
    output logic              cas_n,
    output logic              we_n,
    output logic [2:0]        ba,
    output logic [15:0]       addr,
    output logic [1:0]        odt,
    inout  logic [W-1:0]      dqs_p,
    inout  logic [W-1:0]      dqs_n,
    inout  logic [W*8-1:0]    dq,
    output logic [W-1:0]      dm,
    // Internal signals
    input  logic              reset,     // synchronouse to dclk.
    input  logic              refclk,    // reference clock for io delay stuff, usually 200MHz.
    input  logic              hsclk_90,  // serdes ddr clock
    input  logic              hsclk,     // serdes ddr clock
    input  logic              divclk     // clock for input data to serdesr, 1/8 of hsclk.
    // Training control
);

    localparam int DELGRP = 0;

    // one of these idelayctrl blocks must be instantiated when using IDELAY2 or ODELAY2 blocks with loadable delays.
    logic idelayctl_rdy;
    (* IODELAY_GROUP = DELGRP *) IDELAYCTRL IDELAYCTRL_inst ( .RDY(idelayctl_rdy), .REFCLK(refclk), .RST(reset) );

    // make the ck_p/n outputs with an oddr and obufds.
    logic [1:0] ck_pre;
    ODDR #(.DDR_CLK_EDGE("SAME_EDGE"),.INIT(1'b0),.SRTYPE("SYNC")) ODDR_inst (.Q(ck_pre[1]),.C(hsclk_90),.CE(1),.D1(0),.D2(1),.R(0),.S(0));
    ODDR #(.DDR_CLK_EDGE("SAME_EDGE"),.INIT(1'b0),.SRTYPE("SYNC")) ODDR_inst (.Q(ck_pre[0]),.C(hsclk_90),.CE(1),.D1(0),.D2(1),.R(0),.S(0));
    OBUFDS #(.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) OBUFDS_ck1_inst (.O(ck_p[1]),.OB(ck_n[1]),.I(ck_pre[1]));
    OBUFDS #(.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) OBUFDS_ck0_inst (.O(ck_p[0]),.OB(ck_n[0]),.I(ck_pre[0]));

    // logic for the dq lines.
    logic [W*8-1:0]    dq_out, dq_in;
    genvar i;
    generate for(i=0; i<W*8; i++) begin
        OSERDESE2 #(
            .DATA_RATE_OQ("DDR"),   // DDR, SDR
            .DATA_RATE_TQ("DDR"),   // DDR, BUF, SDR
            .DATA_WIDTH(8),         // Parallel data width (2-8,10,14)
            .INIT_OQ(1'b0),         // Initial value of OQ output (1'b0,1'b1)
            .INIT_TQ(1'b0),         // Initial value of TQ output (1'b0,1'b1)
            .SERDES_MODE("MASTER"), // MASTER, SLAVE
            .SRVAL_OQ(1'b0),        // OQ output value when SR is used (1'b0,1'b1)
            .SRVAL_TQ(1'b0),        // TQ output value when SR is used (1'b0,1'b1)
            .TBYTE_CTL("FALSE"),    // Enable tristate byte operation (FALSE, TRUE)
            .TBYTE_SRC("FALSE"),    // Tristate byte source (FALSE, TRUE)
            .TRISTATE_WIDTH(4)      // 3-state converter width (1,4)
        ) OSERDESE2_dq_inst (
            .OFB(),             // 1-bit output: Feedback path for data
            .OQ(dq_out[i]),               // 1-bit output: Data path output
            .SHIFTOUT1(),
            .SHIFTOUT2(),
            .TBYTEOUT(),   // 1-bit output: Byte group tristate
            .TFB(),             // 1-bit output: 3-state control
            .TQ(),               // 1-bit output: 3-state control
            .CLK(hsclk),             // 1-bit input: High speed clock
            .CLKDIV(divclk),       // 1-bit input: Divided clock    
            .D1(1'b1),
            .D2(1'b0),
            .D3(1'b1),
            .D4(1'b1),
            .D5(1'b0),
            .D6(1'b0),
            .D7(1'b0),
            .D8(1'b0),
            .OCE(1'b1),             // 1-bit input: Output data clock enable
            .RST(reset),             // 1-bit input: Reset
            .SHIFTIN1(1'b0),
            .SHIFTIN2(1'b0),
            .T1(1'b0),
            .T2(1'b0),
            .T3(1'b0),
            .T4(1'b0),
            .TBYTEIN(1'b0),     // 1-bit input: Byte group tristate
            .TCE(1'b1)              // 1-bit input: 3-state clock enable
        );

// we need iserdes here.

        // programmable input delay 
        (* IODELAY_GROUP = 0 *)
        IDELAYE2 #(
            .CINVCTRL_SEL("FALSE"), 
            .DELAY_SRC("IDATAIN"), 
            .HIGH_PERFORMANCE_MODE("TRUE"), 
            .IDELAY_TYPE("VAR_LOAD"), 
            .IDELAY_VALUE(0), 
            .PIPE_SEL("FALSE"), 
            .REFCLK_FREQUENCY(200.0), 
            .SIGNAL_PATTERN("DATA") 
        ) IDELAYE2_inst (
            .CNTVALUEOUT(),     // 5-bit
            .DATAOUT(idataout), // 1-bit
            .C(clk),            // 1-bit
            .CE(0),             // 1-bit
            .CINVCTRL(0),       // 1-bit
            .CNTVALUEIN(cntvaluein), // 5-bit
            .DATAIN(0),         // 1-bit
            .IDATAIN(datain),   // 1-bit
            .INC(0),            // 1-bit
            .LD(ld),            // 1-bit
            .LDPIPEEN(0),       // 1-bit
            .REGRST(regrst)     // 1-bit
        );

        // programmable output delay 
        (* IODELAY_GROUP = 0 *)
        ODELAYE2 #(
            .CINVCTRL_SEL("FALSE"),     // Enable dynamic clock inversion (FALSE, TRUE)
            .DELAY_SRC("ODATAIN"),      // Delay input (ODATAIN, CLKIN)
            .HIGH_PERFORMANCE_MODE("TRUE"), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
            .ODELAY_TYPE("VAR_LOAD"),  // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
            .ODELAY_VALUE(0),           // Output delay tap setting (0-31)
            .PIPE_SEL("FALSE"),          // Select pipelined mode, FALSE, TRUE
            .REFCLK_FREQUENCY(200.0),   // IDELAYCTRL clock input frequency in MHz (190.0-210.0).
            .SIGNAL_PATTERN("DATA")     // DATA, CLOCK input signal
        ) ODELAYE2_inst (
            .CNTVALUEOUT(cntvalueout),  // 5-bit output: Counter value output
            .DATAOUT(odataout),          // 1-bit output: Delayed data/clock output
            .C(clk),                    // 1-bit input: Clock input
            .CE(0),                     // 1-bit input: Active high enable increment/decrement input
            .CINVCTRL(0),               // 1-bit input: Dynamic clock inversion input
            .CLKIN(0),                  // 1-bit input: Clock delay input
            .CNTVALUEIN(cntvaluein),    // 5-bit input: Counter value input
            .INC(0),                    // 1-bit input: Increment / Decrement tap delay input
            .LD(ld),                    // 1-bit input: Loads ODELAY_VALUE tap delay in VARIABLE mode, in VAR_LOAD or VAR_LOAD_PIPE mode, loads the value of CNTVALUEIN
            .LDPIPEEN(0),         // 1-bit input: Enables the pipeline register to load data
            .ODATAIN(datain),          // 1-bit input: Output delay data input
            .REGRST(regrst)             // 1-bit input: Active-high reset tap-delay input
        );

        // bidirectional io buffer with termination control
        IOBUF_DCIEN #(.DRIVE(12),.IBUF_LOW_PWR("TRUE"),.IOSTANDARD("DEFAULT"),.SLEW("SLOW"),.USE_IBUFDISABLE("FALSE")) 
        IOBUF_DCIEN_dq_inst (.I(dq_out[i]),.IO(dq[i]),.DCITERMDISABLE(?),.O(dq_in[i]),.IBUFDISABLE(),.T(?));

    end endgenerate

endmodule

