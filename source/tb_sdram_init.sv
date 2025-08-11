/*
Copyright (c) 2025 Namaste FPGA Technologies
 
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
 
 
 
`timescale 1ns / 1ps
 
module tb_sdram_init;
 
  // --------------------------------------------------
  // Clock and Reset Declarations
  // --------------------------------------------------
  reg               s_clk    = 0;     // System clock
  reg               s_rstn   = 0;     // Active-low reset
 
  // --------------------------------------------------
  // SDRAM Initialization Controller Outputs
  // --------------------------------------------------
  wire [3:0]        init_cmd;        // SDRAM command signals (CS, RAS, CAS, WE)
  wire [1:0]        init_ba;         // Bank address
  wire [11:0]       init_addr;       // Address bus
  wire              init_done;       // Initialization done signal
 
  // --------------------------------------------------
  // Clock Generation: 100 MHz clock with 10ns period
  // --------------------------------------------------
  always #5 s_clk = ~s_clk;
 
  // --------------------------------------------------
  // Reset Generation: Assert for 3 clock cycles
  // --------------------------------------------------
  initial begin
    s_rstn = 1'b0;
    repeat(3) @(posedge s_clk);
    s_rstn = 1'b1;
  end
 
  // --------------------------------------------------
  // Simulation End Condition
  // --------------------------------------------------
  initial begin
    @(posedge init_done);   // Wait until initialization completes
    @(posedge s_clk);       // Wait one more cycle
    $finish;                // End simulation
  end
 
  // --------------------------------------------------
  // Instantiate DUT: SDRAM Initialization Controller
  // --------------------------------------------------
  sdram_init sdram_init_inst (
    .sys_clk     (s_clk),        // System clock
    .sys_rst_n   (s_rstn),       // Active-low reset
    .init_cmd    (init_cmd),     // Command output
    .init_ba     (init_ba),      // Bank address output
    .init_addr   (init_addr),    // Address bus output
    .init_done   (init_done)     // Initialization done signal
  );
 
  // --------------------------------------------------
  // Optional: Instantiate SDRAM Model for Command Monitoring
  // --------------------------------------------------
  sdram_model_plus sdram_model_plus_inst (
    .Dq     (/* unused for init */),    // Data bus not used during init
    .Addr   (init_addr),               // SDRAM address
    .Ba     (init_ba),                 // SDRAM bank address
    .Clk    (s_clk),                   // Clock
    .Cke    (1'b1),                    // Clock enable (always ON)
    .Cs_n   (init_cmd[3]),             // Chip select
    .Ras_n  (init_cmd[2]),             // Row address strobe
    .Cas_n  (init_cmd[1]),             // Column address strobe
    .We_n   (init_cmd[0]),             // Write enable
    .Dqm    (2'b00),                   // Data mask (disabled)
    .Debug  (1'b1)                     // Debug mode ON
  );
 
endmodule
 