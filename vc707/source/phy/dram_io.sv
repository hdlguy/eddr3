//
module dram_io #(
    parameter int  W = 8  // width of dram interface in bytes.
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
//    inout  logic [W-1:0]      dqs_p,
//    inout  logic [W-1:0]      dqs_n,
//    inout  logic [W*8-1:0]    dq,
    output logic [W-1:0]      dm,
    // Internal signals
    input  logic              reset,  // synchronouse to dclk.
    input  logic              refclk, // reference clock for io delay stuff, usually 200MHz.
    input  logic              hsclk,  // serdes ddr clock
    input  logic              dclk    // clock for input data to serdesr, 1/8 of hsclk.
    // Training control
);

    localparam int DELGRP = 0;

    // one of these idelayctrl blocks must be instantiated when using IDELAY2 or ODELAY2 blocks with loadable delays.
    logic idelayctl_rdy;
    (* IODELAY_GROUP = DELGRP *) IDELAYCTRL IDELAYCTRL_inst ( .RDY(idelayctl_rdy), .REFCLK(refclk), .RST(reset) );

    // make the ck_p/n outputs with an oserdes and obufds.
    logic ck_pre;
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
    ) OSERDESE2_ck_inst (
        .OFB(),             // 1-bit output: Feedback path for data
        .OQ(ck_pre),               // 1-bit output: Data path output
        .SHIFTOUT1(),
        .SHIFTOUT2(),
        .TBYTEOUT(),         // 1-bit output: Byte group tristate
        .TFB(),              // 1-bit output: 3-state control
        .TQ(),               // 1-bit output: 3-state control
        .CLK(hsclk),         // 1-bit input: High speed clock
        .CLKDIV(dclk),       // 1-bit input: Divided clock
        .D1(1),
        .D2(0),
        .D3(1),
        .D4(0),
        .D5(1),
        .D6(0),
        .D7(1),
        .D8(0),
        .OCE(1),             // 1-bit input: Output data clock enable
        .RST(reset),             // 1-bit input: Reset
        .SHIFTIN1(0),
        .SHIFTIN2(0),
        .T1(0),
        .T2(0),
        .T3(0),
        .T4(0),
        .TBYTEIN(0),     // 1-bit input: Byte group tristate
        .TCE(0)              // 1-bit input: 3-state clock enable
    );    
    OBUFDS #(.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) OBUFDS_ck1_inst (.O(ck_p[1]),.OB(ck_n[1]),.I(ck_pre));
    OBUFDS #(.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) OBUFDS_ck0_inst (.O(ck_p[0]),.OB(ck_n[0]),.I(ck_pre));

/*
    (* IODELAY_GROUP = DELGRP *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL   
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
        .CNTVALUEOUT(),  // 5-bit output: Counter value output
        .DATAOUT(),          // 1-bit output: Delayed data/clock output
        .C(),                    // 1-bit input: Clock input
        .CE(0),                     // 1-bit input: Active high enable increment/decrement input
        .CINVCTRL(0),               // 1-bit input: Dynamic clock inversion input
        .CLKIN(0),                  // 1-bit input: Clock delay input
        .CNTVALUEIN(),    // 5-bit input: Counter value input
        .INC(0),                    // 1-bit input: Increment / Decrement tap delay input
        .LD(),                    // 1-bit input: Loads ODELAY_VALUE tap delay in VARIABLE mode, in VAR_LOAD or VAR_LOAD_PIPE mode, loads the value of CNTVALUEIN
        .LDPIPEEN(0),         // 1-bit input: Enables the pipeline register to load data
        .ODATAIN(),          // 1-bit input: Output delay data input
        .REGRST()             // 1-bit input: Active-high reset tap-delay input
    );

    (* IODELAY_GROUP = DELGRP *)
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

    OBUFDS #(.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) OBUFDS_inst (.O(),.OB(),.I());
    OBUF #(.DRIVE(12),.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) OBUF_inst ( .O(), .I() );
    IBUF #(.IBUF_LOW_PWR("TRUE"),.IOSTANDARD("DEFAULT")) IBUF_inst ( .O(), .I());

    IOBUFDS_DCIEN #(
        .DIFF_TERM("FALSE"),     // Differential Termination ("TRUE"/"FALSE")
        .IBUF_LOW_PWR("TRUE"),   // Low Power - "TRUE", High Performance = "FALSE" 
        .IOSTANDARD("BLVDS_25"), // Specify the I/O standard
        .SLEW("SLOW"),           // Specify the output slew rate
        .USE_IBUFDISABLE("TRUE") // Use IBUFDISABLE function, "TRUE" or "FALSE" 
    ) IOBUFDS_DCIEN_inst (
        .O(O),     // Buffer output
        .IO(IO),   // Diff_p inout (connect directly to top-level port)
        .IOB(IOB), // Diff_n inout (connect directly to top-level port)
        .DCITERMDISABLE(DCITERMDISABLE), // DCI Termination enable input
        .I(I),                           // Buffer input
        .IBUFDISABLE(IBUFDISABLE),       // Input disable input, high=disable
        .T(T)      // 3-state enable input, high=input, low=output
    );

    IOBUF_DCIEN #(
        .DRIVE(12), // Specify the output drive strength
        .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
        .IOSTANDARD("DEFAULT"), // Specify the I/O standard
        .SLEW("SLOW"),          // Specify the output slew rate
        .USE_IBUFDISABLE("TRUE") // Use IBUFDISABLE function, "TRUE" or "FALSE" 
    ) IOBUF_DCIEN_inst (
        .O(O),     // Buffer output
        .IO(IO),   // Buffer inout port (connect directly to top-level port)
        .DCITERMDISABLE(DCITERMDISABLE), // DCI Termination enable input
        .I(I),     // Buffer input
        .IBUFDISABLE(IBUFDISABLE), // Input disable input, high=disable
        .T(T)      // 3-state enable input, high=input, low=output
    );

    ISERDESE2 #(
        .DATA_RATE("DDR"),           // DDR, SDR
        .DATA_WIDTH(4),              // Parallel data width (2-8,10,14)
        .DYN_CLKDIV_INV_EN("FALSE"), // Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
        .DYN_CLK_INV_EN("FALSE"),    // Enable DYNCLKINVSEL inversion (FALSE, TRUE)
        // INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
        .INIT_Q1(1'b0),
        .INIT_Q2(1'b0),
        .INIT_Q3(1'b0),
        .INIT_Q4(1'b0),
        .INTERFACE_TYPE("MEMORY"),   // MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
        .IOBDELAY("NONE"),           // NONE, BOTH, IBUF, IFD
        .NUM_CE(2),                  // Number of clock enables (1,2)
        .OFB_USED("FALSE"),          // Select OFB path (FALSE, TRUE)
        .SERDES_MODE("MASTER"),      // MASTER, SLAVE
        // SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
        .SRVAL_Q1(1'b0),
        .SRVAL_Q2(1'b0),
        .SRVAL_Q3(1'b0),
        .SRVAL_Q4(1'b0)
    ) ISERDESE2_inst (
        .O(O),                       // 1-bit output: Combinatorial output
        // Q1 - Q8: 1-bit (each) output: Registered data outputs
        .Q1(Q1),
        .Q2(Q2),
        .Q3(Q3),
        .Q4(Q4),
        .Q5(Q5),
        .Q6(Q6),
        .Q7(Q7),
        .Q8(Q8),
        // SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
        .SHIFTOUT1(SHIFTOUT1),
        .SHIFTOUT2(SHIFTOUT2),
        .BITSLIP(BITSLIP),           // 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
                                   // CLKDIV when asserted (active High). Subsequently, the data seen on the Q1
                                   // to Q8 output ports will shift, as in a barrel-shifter operation, one
                                   // position every time Bitslip is invoked (DDR operation is different from
                                   // SDR).

        // CE1, CE2: 1-bit (each) input: Data register clock enable inputs
        .CE1(CE1),
        .CE2(CE2),
        .CLKDIVP(CLKDIVP),           // 1-bit input: TBD
        // Clocks: 1-bit (each) input: ISERDESE2 clock input ports
        .CLK(CLK),                   // 1-bit input: High-speed clock
        .CLKB(CLKB),                 // 1-bit input: High-speed secondary clock
        .CLKDIV(CLKDIV),             // 1-bit input: Divided clock
        .OCLK(OCLK),                 // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
        // Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
        .DYNCLKDIVSEL(DYNCLKDIVSEL), // 1-bit input: Dynamic CLKDIV inversion
        .DYNCLKSEL(DYNCLKSEL),       // 1-bit input: Dynamic CLK/CLKB inversion
        // Input Data: 1-bit (each) input: ISERDESE2 data input ports
        .D(D),                       // 1-bit input: Data input
        .DDLY(DDLY),                 // 1-bit input: Serial data from IDELAYE2
        .OFB(OFB),                   // 1-bit input: Data feedback from OSERDESE2
        .OCLKB(OCLKB),               // 1-bit input: High speed negative edge output clock
        .RST(RST),                   // 1-bit input: Active high asynchronous reset
        // SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
        .SHIFTIN1(SHIFTIN1),
        .SHIFTIN2(SHIFTIN2)
    );

    OSERDESE2 #(
        .DATA_RATE_OQ("DDR"),   // DDR, SDR
        .DATA_RATE_TQ("DDR"),   // DDR, BUF, SDR
        .DATA_WIDTH(4),         // Parallel data width (2-8,10,14)
        .INIT_OQ(1'b0),         // Initial value of OQ output (1'b0,1'b1)
        .INIT_TQ(1'b0),         // Initial value of TQ output (1'b0,1'b1)
        .SERDES_MODE("MASTER"), // MASTER, SLAVE
        .SRVAL_OQ(1'b0),        // OQ output value when SR is used (1'b0,1'b1)
        .SRVAL_TQ(1'b0),        // TQ output value when SR is used (1'b0,1'b1)
        .TBYTE_CTL("FALSE"),    // Enable tristate byte operation (FALSE, TRUE)
        .TBYTE_SRC("FALSE"),    // Tristate byte source (FALSE, TRUE)
        .TRISTATE_WIDTH(4)      // 3-state converter width (1,4)
    ) OSERDESE2_inst (
        .OFB(OFB),             // 1-bit output: Feedback path for data
        .OQ(OQ),               // 1-bit output: Data path output
        // SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
        .SHIFTOUT1(SHIFTOUT1),
        .SHIFTOUT2(SHIFTOUT2),
        .TBYTEOUT(TBYTEOUT),   // 1-bit output: Byte group tristate
        .TFB(TFB),             // 1-bit output: 3-state control
        .TQ(TQ),               // 1-bit output: 3-state control
        .CLK(CLK),             // 1-bit input: High speed clock
        .CLKDIV(CLKDIV),       // 1-bit input: Divided clock
        // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
        .D1(D1),
        .D2(D2),
        .D3(D3),
        .D4(D4),
        .D5(D5),
        .D6(D6),
        .D7(D7),
        .D8(D8),
        .OCE(OCE),             // 1-bit input: Output data clock enable
        .RST(RST),             // 1-bit input: Reset
        // SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
        .SHIFTIN1(SHIFTIN1),
        .SHIFTIN2(SHIFTIN2),
        // T1 - T4: 1-bit (each) input: Parallel 3-state inputs
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .T4(T4),
        .TBYTEIN(TBYTEIN),     // 1-bit input: Byte group tristate
        .TCE(TCE)              // 1-bit input: 3-state clock enable
    );
*/

endmodule

