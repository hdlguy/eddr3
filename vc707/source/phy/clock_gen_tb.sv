`timescale 1ns / 1ps

module clock_gen_tb();

    logic        reset;
    logic        clkin;
    logic        hsclk_90;
    logic        hsclk;
    logic        divclk;
    logic        locked;

    localparam refclk_period = 5;
    logic refclk;
    initial forever begin
        refclk = 0;
        #(refclk_period/2);
        refclk = 1;
        #(refclk_period/2);
    end
    assign clkin = refclk;
    
    initial begin
        reset = 1;
        #(refclk_period*20)
        reset = 0;
    end

    clock_gen uut (.*);

endmodule    
                  


    
