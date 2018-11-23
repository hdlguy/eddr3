//
module clock_gen (
    input logic         clkin,      // PLL reference clock.
    input logic         reset,
    //
    output logic        hsclk_90,   // fast clock to feed the ODDR of ck_p/n
    output logic        hsclk,      // fast clock to feed the SERDES of data and control pins
    output logic        divclk,     // divided clock to feed the SERDES of data and control pins
    output logic        locked
);


    // Generate the clocks with a PLL
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
        .CLKOUT0_PHASE(90.0), // shifted clock for the ODDR of ck_p/n
        .CLKOUT1_PHASE(0.0),  // fast clock for the SERDES
        .CLKOUT2_PHASE(0.0),  // divided clock for the SERDES
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
endmodule
