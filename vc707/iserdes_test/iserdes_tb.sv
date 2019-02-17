`timescale 1 ns / 1 ps 
//
module iserdes_tb ();

    logic hsclk, divclk;

    localparam hsclk_period = 2;
    localparam divclk_period = hsclk_period*2;
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
        divclk = 0;
        #(hsclk_period/2);
    end
    
    logic reset;    
    initial begin
        reset = 1;
        #(divclk_period*10.5);
        reset = 0;
    end 
    
    logic din, ld;
    logic [3:0] dcount;
    always_ff @(posedge divclk) begin
        if (1 == reset) begin
            dcount <= 8'hfa;
            ld <= 0;
        end else begin
            ld <= ~ld;
            dcount <= dcount+1;
        end
    end
    
    logic ld_reg;
    logic [3:0] shift_reg;
    always_ff @(hsclk) begin
        ld_reg <= ld;
        if (ld_reg != ld) begin
            shift_reg <= dcount;
        end else begin
            shift_reg[3:1] <= shift_reg[2:0];
            shift_reg[0] <= 0;
        end
    end
    assign #0.1 din = shift_reg[3];
    

    logic [3:0] q;
    ISERDESE2 #(
        .DATA_RATE("DDR"),
        .DATA_WIDTH(4),
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
        .Q1(q[0]), .Q2(q[1]), .Q3(q[2]), .Q4(q[3]), .Q5(), .Q6(), .Q7(), .Q8(),
        .SHIFTOUT1(),
        .SHIFTOUT2(),
        .BITSLIP(1'b0),
        .CE1(1'b1),
        .CE2(1'b1),
        .CLKDIVP(1'b0),
        .CLK ( hsclk),
        .CLKB(~hsclk),
        .CLKDIV(divclk),
        .DYNCLKDIVSEL(1'b0),
        .DYNCLKSEL(1'b0),
        .D(1'b0),
        .DDLY(din),                 // 1-bit input: Serial data from IDELAYE2
        .OFB(1'b0),                   // 1-bit input: Data feedback from OSERDESE2
        .OCLK ( hsclk),                 // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
        .OCLKB(~hsclk),               // 1-bit input: High speed negative edge output clock
        .RST(reset),                   // 1-bit input: Active high asynchronous reset
        .SHIFTIN1(1'b0),
        .SHIFTIN2(1'b0)
    );


endmodule
