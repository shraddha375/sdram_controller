`timescale 1ns / 1ps 

module tb_sdram_load_mode_register();

    reg             s_clk       = 0;   // System Clock
    reg             s_rstn      = 0;   // Active-Low Reset  
    reg             mode_reg_en = 0;   // Self-Refresh Enable
    
    wire [3:0]      sdram_cmd;         // SDRAM Command Bus
    wire [1:0]      sdram_ba;          // SDRAM Bank Address
    wire [11:0]     sdram_addr;        // SDRAM Address Bus
    reg  [11:0]     mode_reg_val;
    wire            mode_reg_done;     // Self-Refresh Done Signal
    
    wire [15:0]     sdram_dq;          // Bi-Directional Data Bus
    wire            init_done;
    
    assign init_done = 1;
    
    // Generate 100MHz clock (10ns period)
    always #5 s_clk = ~s_clk;
 
    // // Initialization block 
    initial begin
        s_rstn = 1'b0;
        repeat(5) @(posedge s_clk);
        s_rstn = 1'b1;

        @(posedge s_clk);
        mode_reg_en = 1;

        @(posedge s_clk);
        mode_reg_val = 12'b00_0_00_011_0_111;

        // Wait for a to complete
        wait(mode_reg_done == 1);
        $display("Load Register Loaded!");
          
        @(posedge s_clk);
        $finish;
    end

    // Instantiate Self-Refresh Module
    sdram_load_mode_register  dut (
        .sys_clk        (s_clk),
        .sys_rst_n      (s_rstn),
        .mode_reg_en    (mode_reg_en),
        .sdram_init     (init_done),
        .mode_reg_val   (mode_reg_val),
        .sdram_cmd      (sdram_cmd),
        .sdram_ba       (sdram_ba),
        .sdram_addr     (sdram_addr),
        .mode_reg_done  (mode_reg_done)
    );

    // Instantiate SDRAM Model
    sdram_model_plus  sdram_model_plus_inst (
        .Dq         (sdram_dq),        // Bi-directional Data Bus
        .Addr       (sdram_addr),      // Address Bus
        .Ba         (sdram_ba),        // Bank Address
        .Clk        (s_clk),           // Clock
        .Cke        (1'b1),       // Clock Enable
        .Cs_n       (sdram_cmd[3]),    // Chip Select
        .Ras_n      (sdram_cmd[2]),    // Row Address Strobe
        .Cas_n      (sdram_cmd[1]),    // Column Address Strobe
        .We_n       (sdram_cmd[0]),    // Write Enable
        .Dqm        (2'b00),           // Data Mask
        .Debug      (1'b1)             // Debug Mode
    );


endmodule