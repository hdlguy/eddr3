`timescale 1ns / 1ps

module mmcm_tb();

    // 200MHz reference clock
    localparam clk_period = 5;
    logic clk, clkin;
    initial forever begin
        clk = 0;
        #(clk_period/2);
        clk = 1;
        #(clk_period/2);
    end
    assign clkin = clk;
    
    // 100MHz DRP clock
    localparam dclk_period = 100;
    logic dclk;
    initial forever begin
        dclk = 0;
        #(dclk_period/2);
        dclk = 1;
        #(dclk_period/2);
    end
    
    logic [15:0] pll_drp_di, pll_drp_do;
    logic [6:0] pll_drp_daddr;
    logic pll_drp_den, pll_drp_dwe, pll_drp_drdy;
    assign pll_drp_di = 0;
    assign pll_drp_daddr = 0;
    assign pll_drp_den = 0;
    assign pll_drp_dwe = 0;
    
    logic reset;
    initial begin
        reset = 1;
        #(clk_period*20)
        reset = 0;
    end

    logic [5:0] pll_clockout;
    logic [5:0] pllclk;
    logic pll_locked, clkfbout, clkfb;
    PLLE2_ADV #(
        .BANDWIDTH("OPTIMIZED"),  // OPTIMIZED, HIGH, LOW
        .CLKFBOUT_MULT(8),        // Multiply value for all CLKOUT, (2-64)
        .CLKFBOUT_PHASE(0.0),     // Phase offset in degrees of CLKFB, (-360.000-360.000).
        // CLKIN_PERIOD: Input clock period in nS to ps resolution (i.e. 33.333 is 30 MHz).
        .CLKIN1_PERIOD(5.0),
        .CLKIN2_PERIOD(5.0),
        // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT (1-128)
        .CLKOUT0_DIVIDE(2),
        .CLKOUT1_DIVIDE(2),
        .CLKOUT2_DIVIDE(8),
        .CLKOUT3_DIVIDE(2),
        .CLKOUT4_DIVIDE(2),
        .CLKOUT5_DIVIDE(2),
        // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.001-0.999).
        .CLKOUT0_DUTY_CYCLE(0.5),
        .CLKOUT1_DUTY_CYCLE(0.5),
        .CLKOUT2_DUTY_CYCLE(0.5),
        .CLKOUT3_DUTY_CYCLE(0.5),
        .CLKOUT4_DUTY_CYCLE(0.5),
        .CLKOUT5_DUTY_CYCLE(0.5),
        // CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
        .CLKOUT0_PHASE(0.0),
        .CLKOUT1_PHASE(90.0),
        .CLKOUT2_PHASE(0.0),
        .CLKOUT3_PHASE(0.0),
        .CLKOUT4_PHASE(0.0),
        .CLKOUT5_PHASE(0.0),
        .COMPENSATION("ZHOLD"),   // ZHOLD, BUF_IN, EXTERNAL, INTERNAL
        .DIVCLK_DIVIDE(1),        // Master division value (1-56)
        // REF_JITTER: Reference input jitter in UI (0.000-0.999).
        .REF_JITTER1(0.0),
        .REF_JITTER2(0.0),
        .STARTUP_WAIT("FALSE")    // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
    )
    PLLE2_ADV_inst (
        // Clock Inputs: 1-bit (each) input: Clock inputs
        .CLKIN1(clkin),     // 1-bit input: Primary clock
        .CLKIN2(1'b0),     // 1-bit input: Secondary clock
        // Clock Outputs: 1-bit (each) output: User configurable clock outputs
        .CLKOUT0(pll_clockout[0]),
        .CLKOUT1(pll_clockout[1]),
        .CLKOUT2(pll_clockout[2]),
        .CLKOUT3(pll_clockout[3]),
        .CLKOUT4(pll_clockout[4]),
        .CLKOUT5(pll_clockout[5]),
        .CLKFBIN(clkfb),    // 1-bit input: Feedback clock
        .CLKFBOUT(clkfbout), // 1-bit output: Feedback clock
        .LOCKED(pll_locked),     // 1-bit output: LOCK
        .CLKINSEL(1'b1), // 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
        .PWRDWN(1'b0),     // 1-bit input: Power-down
        .RST(reset),           // 1-bit input: Reset
        // DRP Ports
        .DO(pll_drp_do),             // 16-bit output: DRP data
        .DRDY(pll_drp_drdy),         // 1-bit output: DRP ready
        .DADDR(pll_drp_daddr),       // 7-bit input: DRP address
        .DCLK(dclk),         // 1-bit input: DRP clock
        .DEN(pll_drp_den),           // 1-bit input: DRP enable
        .DI(pll_drp_di),             // 16-bit input: DRP data
        .DWE(pll_drp_dwe)           // 1-bit input: DRP write enable
    );
    BUFG BUFG_clkfb (.O(clkfb), .I(clkfbout));
    genvar i;
    generate for (i=0; i<6; i++) begin
        BUFG BUFG_pllclk (.O(pllclk[i]), .I(pll_clockout[i]));
    end endgenerate
    
    logic ck_pre;
    ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
        .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
        .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
    ) ODDR_inst (
        .Q(ck_pre),   // 1-bit DDR output
        .C(pllclk[1]),   // 1-bit clock input
        .CE(1), // 1-bit clock enable input
        .D1(0), // 1-bit data input (positive edge)
        .D2(1), // 1-bit data input (negative edge)
        .R(0),   // 1-bit reset
        .S(0)    // 1-bit set
    );

    logic ck_p, ck_n;
    OBUFDS #(.IOSTANDARD("DEFAULT"), .SLEW("SLOW")) OBUFDS_ck_inst (.O(ck_p), .OB(ck_n), .I(ck_pre));
    
    logic dq_pre;
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
        .OQ(dq_pre),               // 1-bit output: Data path output
        // SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
        .SHIFTOUT1(),
        .SHIFTOUT2(),
        .TBYTEOUT(),   // 1-bit output: Byte group tristate
        .TFB(),             // 1-bit output: 3-state control
        .TQ(),               // 1-bit output: 3-state control
        .CLK(pllclk[0]),             // 1-bit input: High speed clock
        .CLKDIV(pllclk[2]),       // 1-bit input: Divided clock
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
    logic dq;
    OBUF #(.DRIVE(12),.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) OBUF_dq_inst (.O(dq),.I(dq_pre));
    
endmodule    
               
    
    // logic [31:0] pllcount [5:0];
    // always_ff @(posedge pllclk[i]) begin pllcount[i] <= pllcount[i] + 1; led[i] <= pllcount[i][28]; end 

/*
   MMCME2_ADV #(
      .BANDWIDTH("OPTIMIZED"),        // Jitter programming (OPTIMIZED, HIGH, LOW)
      .CLKFBOUT_MULT_F(5.0),          // Multiply value for all CLKOUT (2.000-64.000).
      .CLKFBOUT_PHASE(0.0),           // Phase offset in degrees of CLKFB (-360.000-360.000).
      // CLKIN_PERIOD: Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      .CLKIN1_PERIOD(0.0),
      .CLKIN2_PERIOD(0.0),
      // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for CLKOUT (1-128)
      .CLKOUT1_DIVIDE(1),
      .CLKOUT2_DIVIDE(1),
      .CLKOUT3_DIVIDE(1),
      .CLKOUT4_DIVIDE(1),
      .CLKOUT5_DIVIDE(1),
      .CLKOUT6_DIVIDE(1),
      .CLKOUT0_DIVIDE_F(1.0),         // Divide amount for CLKOUT0 (1.000-128.000).
      // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.01-0.99).
      .CLKOUT0_DUTY_CYCLE(0.5),
      .CLKOUT1_DUTY_CYCLE(0.5),
      .CLKOUT2_DUTY_CYCLE(0.5),
      .CLKOUT3_DUTY_CYCLE(0.5),
      .CLKOUT4_DUTY_CYCLE(0.5),
      .CLKOUT5_DUTY_CYCLE(0.5),
      .CLKOUT6_DUTY_CYCLE(0.5),
      // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
      .CLKOUT0_PHASE(0.0),
      .CLKOUT1_PHASE(0.0),
      .CLKOUT2_PHASE(0.0),
      .CLKOUT3_PHASE(0.0),
      .CLKOUT4_PHASE(0.0),
      .CLKOUT5_PHASE(0.0),
      .CLKOUT6_PHASE(0.0),
      .CLKOUT4_CASCADE("FALSE"),      // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      .COMPENSATION("ZHOLD"),         // ZHOLD, BUF_IN, EXTERNAL, INTERNAL
      .DIVCLK_DIVIDE(1),              // Master division value (1-106)
      // REF_JITTER: Reference input jitter in UI (0.000-0.999).
      .REF_JITTER1(0.0),
      .REF_JITTER2(0.0),
      .STARTUP_WAIT("FALSE"),         // Delays DONE until MMCM is locked (FALSE, TRUE)
      // Spread Spectrum: Spread Spectrum Attributes
      .SS_EN("FALSE"),                // Enables spread spectrum (FALSE, TRUE)
      .SS_MODE("CENTER_HIGH"),        // CENTER_HIGH, CENTER_LOW, DOWN_HIGH, DOWN_LOW
      .SS_MOD_PERIOD(10000),          // Spread spectrum modulation period (ns) (VALUES)
      // USE_FINE_PS: Fine phase shift enable (TRUE/FALSE)
      .CLKFBOUT_USE_FINE_PS("FALSE"),
      .CLKOUT0_USE_FINE_PS("FALSE"),
      .CLKOUT1_USE_FINE_PS("FALSE"),
      .CLKOUT2_USE_FINE_PS("FALSE"),
      .CLKOUT3_USE_FINE_PS("FALSE"),
      .CLKOUT4_USE_FINE_PS("FALSE"),
      .CLKOUT5_USE_FINE_PS("FALSE"),
      .CLKOUT6_USE_FINE_PS("FALSE")
   )
   MMCME2_ADV_inst (
      // Clock Outputs: 1-bit (each) output: User configurable clock outputs
      .CLKOUT0(CLKOUT0),           // 1-bit output: CLKOUT0
      .CLKOUT0B(CLKOUT0B),         // 1-bit output: Inverted CLKOUT0
      .CLKOUT1(CLKOUT1),           // 1-bit output: CLKOUT1
      .CLKOUT1B(CLKOUT1B),         // 1-bit output: Inverted CLKOUT1
      .CLKOUT2(CLKOUT2),           // 1-bit output: CLKOUT2
      .CLKOUT2B(CLKOUT2B),         // 1-bit output: Inverted CLKOUT2
      .CLKOUT3(CLKOUT3),           // 1-bit output: CLKOUT3
      .CLKOUT3B(CLKOUT3B),         // 1-bit output: Inverted CLKOUT3
      .CLKOUT4(CLKOUT4),           // 1-bit output: CLKOUT4
      .CLKOUT5(CLKOUT5),           // 1-bit output: CLKOUT5
      .CLKOUT6(CLKOUT6),           // 1-bit output: CLKOUT6
      // DRP Ports: 16-bit (each) output: Dynamic reconfiguration ports
      .DO(DO),                     // 16-bit output: DRP data
      .DRDY(DRDY),                 // 1-bit output: DRP ready
      // Dynamic Phase Shift Ports: 1-bit (each) output: Ports used for dynamic phase shifting of the outputs
      .PSDONE(PSDONE),             // 1-bit output: Phase shift done
      // Feedback Clocks: 1-bit (each) output: Clock feedback ports
      .CLKFBOUT(CLKFBOUT),         // 1-bit output: Feedback clock
      .CLKFBOUTB(CLKFBOUTB),       // 1-bit output: Inverted CLKFBOUT
      // Status Ports: 1-bit (each) output: MMCM status ports
      .CLKFBSTOPPED(CLKFBSTOPPED), // 1-bit output: Feedback clock stopped
      .CLKINSTOPPED(CLKINSTOPPED), // 1-bit output: Input clock stopped
      .LOCKED(LOCKED),             // 1-bit output: LOCK
      // Clock Inputs: 1-bit (each) input: Clock inputs
      .CLKIN1(CLKIN1),             // 1-bit input: Primary clock
      .CLKIN2(CLKIN2),             // 1-bit input: Secondary clock
      // Control Ports: 1-bit (each) input: MMCM control ports
      .CLKINSEL(CLKINSEL),         // 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
      .PWRDWN(PWRDWN),             // 1-bit input: Power-down
      .RST(RST),                   // 1-bit input: Reset
      // DRP Ports: 7-bit (each) input: Dynamic reconfiguration ports
      .DADDR(DADDR),               // 7-bit input: DRP address
      .DCLK(DCLK),                 // 1-bit input: DRP clock
      .DEN(DEN),                   // 1-bit input: DRP enable
      .DI(DI),                     // 16-bit input: DRP data
      .DWE(DWE),                   // 1-bit input: DRP write enable
      // Dynamic Phase Shift Ports: 1-bit (each) input: Ports used for dynamic phase shifting of the outputs
      .PSCLK(PSCLK),               // 1-bit input: Phase shift clock
      .PSEN(PSEN),                 // 1-bit input: Phase shift enable
      .PSINCDEC(PSINCDEC),         // 1-bit input: Phase shift increment/decrement
      // Feedback Clocks: 1-bit (each) input: Clock feedback ports
      .CLKFBIN(CLKFBIN)            // 1-bit input: Feedback clock
   );
*/   


    
