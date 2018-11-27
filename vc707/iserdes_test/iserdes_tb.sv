//
module iserdes_tb ();

    logic hsclk, divclk;

    localparam divclk_period = 8;
    localparam hsclk_period = divclk_period/4;
    initial forever begin
        hsclk = 0;
        divclk = 0;
        #(hsclk_period/2);
        hsclk = 1;
        divclk = 1;
        #(hsclk_period/2);
        hsclk = 0;
        divclk = 1;
        #(hsclk_period/2);
        hsclk = 1;
        divclk = 1;
        #(hsclk_period/2);

        hsclk = 0;
        divclk = 1;
        #(hsclk_period/2);
        hsclk = 1;
        divclk = 0;
        #(hsclk_period/2);
        hsclk = 0;
        divclk = 0;
        #(hsclk_period/2);
        hsclk = 1;
        divclk = 0;
        #(hsclk_period/2);
    end
    
    logic reset, bitslip;    
    initial begin
        reset = 1;
        bitslip = 0;
        #(divclk_period*10);
        reset = 0;
        forever begin
            bitslip = 0;
            #(divclk_period*99);            
            bitslip = 1;
            #(divclk_period*1);
        end
    end 
    
    logic din, ld;
    logic [7:0] dcount;
    always_ff @(posedge divclk) begin
        if (1 == reset) begin
            dcount <= 8'hfa;
            ld <= 0;
        end else begin
            ld <= ~ld;
//            dcount <= dcount+1;
        end
    end
    
    logic ld_reg;
    logic [7:0] shift_reg;
    always_ff @(hsclk) begin
        ld_reg <= ld;
        if (ld_reg != ld) begin
            shift_reg <= dcount;
        end else begin
            shift_reg[7:1] <= shift_reg[6:0];
            shift_reg[0] <= 0;
        end
    end
    assign din = shift_reg[7];
    

    logic [7:0] q;
    ISERDESE2 #(
        .DATA_RATE("DDR"),
        .DATA_WIDTH(8),
        .DYN_CLKDIV_INV_EN("FALSE"),
        .DYN_CLK_INV_EN("FALSE"),
        .INIT_Q1(1'b0),
        .INIT_Q2(1'b0),
        .INIT_Q3(1'b0),
        .INIT_Q4(1'b0),
        .INTERFACE_TYPE("MEMORY"),   // MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
        .IOBDELAY("BOTH"),
        .NUM_CE(1),
        .OFB_USED("FALSE"),
        .SERDES_MODE("MASTER"),
        .SRVAL_Q1(1'b0),
        .SRVAL_Q2(1'b0),
        .SRVAL_Q3(1'b0),
        .SRVAL_Q4(1'b0)
    ) uut (
        .O(),
        .Q1(q[0]), .Q2(q[1]), .Q3(q[2]), .Q4(q[3]), .Q5(q[4]), .Q6(q[5]), .Q7(q[6]), .Q8(q[7]),
        .SHIFTOUT1(),
        .SHIFTOUT2(),
        .BITSLIP(bitslip),
        .CE1(1'b1),
        .CE2(1'b1),
        .CLKDIVP(1'b0),
        .CLK(hsclk),
        .CLKB(~hsclk),
        .CLKDIV(divclk),
        .DYNCLKDIVSEL(1'b0),
        .DYNCLKSEL(1'b0),
        .D(1'bX),
        .DDLY(din),                 // 1-bit input: Serial data from IDELAYE2
        .OFB(1'b0),                   // 1-bit input: Data feedback from OSERDESE2
        .OCLK (divclk),                 // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
        .OCLKB(~divclk),               // 1-bit input: High speed negative edge output clock
        .RST(reset),                   // 1-bit input: Active high asynchronous reset
        .SHIFTIN1(1'b0),
        .SHIFTIN2(1'b0)
    );


endmodule
