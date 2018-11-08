`timescale 1ns / 1ps

module io_delay_tb();


    localparam clk_period = 10;
    logic clk;
    initial forever begin
        clk = 0;
        #(clk_period/2);
        clk = 1;
        #(clk_period/2);
    end
    
    logic [4:0] cntvalueout, cntvaluein;
    logic idataout, odataout, datain, regrst, ld;
        
    initial forever begin
        datain = 0;
        #(clk_period/4);        
        datain = 1;
        #(clk_period/4);
    end
    
    initial begin
        regrst = 1;
        ld = 0;
        cntvaluein = 5'b00000;
        #(clk_period*10);
        regrst = 0;
        #(clk_period*10);
        
        cntvaluein = 5'b00000;
        ld = 1;
        #(clk_period*1)
        ld = 0;   
        
        #(clk_period*20);
        
        cntvaluein = 5'b11111;
        ld = 1;
        #(clk_period*1);
        ld = 0;   
    end


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


    localparam refclk_period = 5;
    logic refclk;
    initial forever begin
        refclk = 0;
        #(refclk_period/2);
        refclk = 1;
        #(refclk_period/2);
    end
    
    logic idelayctl_rdy;
    (* IODELAY_GROUP = 0 *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL
    IDELAYCTRL IDELAYCTRL_inst (
        .RDY(idelayctl_rdy),// 1-bit output: Ready output
        .REFCLK(refclk), // 1-bit input: Reference clock input
        .RST(regrst)// 1-bit input: Active high reset input
    );


endmodule
