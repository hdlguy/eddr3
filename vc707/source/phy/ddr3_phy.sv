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
    input  [W*8-1:0]    odatain;
    output [W*8-1:0]    idataout;
    // Training control

);


    // one of these idelayctrl blocks must be instantiated when using IDELAY2 or ODELAY2 blocks with loadable delays.
    logic idelayctl_rdy;
    (* IODELAY_GROUP = 0 *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL
    IDELAYCTRL IDELAYCTRL_inst ( .RDY(idelayctl_rdy), .REFCLK(refclk), .RST(regrst) );


    (* IODELAY_GROUP = 0 *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL   
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


endmodule

