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
 
module tb_sdram_top_struct;
 
  // Clock and Reset
  reg sys_clk;
  reg sys_rst_n;
 
  // Inputs to DUT
  reg wr_req;
  reg [24:0] wr_addr;
  reg [15:0] wr_data;
  reg [9:0]  wr_burst_len;
  reg        wr_dqm;
 
  // Outputs from DUT
  wire wr_end;
  wire busy;
  wire err;
  wire new_data;
  wire [15:0] wr_datao;
  wire [11:0] addro;
  wire [1:0]  bao;
  wire [3:0]  cmdo;
 
  // Instantiate DUT
  sdram_top_struct uut (
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .wr_req      (wr_req),
    .wr_end      (wr_end),
    .wr_addr     (wr_addr),
    .wr_data     (wr_data),
    .wr_burst_len(wr_burst_len),
    .wr_dqm      (wr_dqm),
    .busy        (busy),
    .err         (err),
    .new_data    (new_data),
    .wr_datao    (wr_datao),
    .addro       (addro),
    .bao         (bao),
    .cmdo        (cmdo)
  );
  
  sdram_model_plus sdram_model_plus_inst (
    .Dq     (wr_datao),
    .Addr   (addro),
    .Ba     (bao),
    .Clk    (sys_clk),
    .Cke    (1'b1),
    .Cs_n   (cmdo[3]),
    .Ras_n  (cmdo[2]),
    .Cas_n  (cmdo[1]),
    .We_n   (cmdo[0]),
    .Dqm    (wr_dqm),
    .Debug  (1'b1)
  );
  
 
  // Clock Generation
  initial begin
    sys_clk = 0;
    forever #5 sys_clk = ~sys_clk;  // 100 MHz clock
  end
 
  // Stimulus
  initial begin
    // Initial values
    sys_rst_n     = 0;
    wr_req        = 0;
    wr_addr       = 25'd0;
    wr_data       = 16'h0000;
    wr_burst_len  = 10'd0;
    wr_dqm        = 0;
 
    // Apply reset
    #20;
    sys_rst_n = 1;
 
    // Wait a bit after reset
    #20;
    @(negedge busy);
    @(posedge sys_clk);
    // Start Write Request
    wr_addr      = 25'b11_000000000001_0_00_00000001;
    wr_data      = 16'h1;
    wr_burst_len = 10'd8;
    wr_dqm       = 1'b0;
    wr_req       = 1;  
    @(posedge new_data);
    wr_req = 1;
    repeat(8) begin
     @(posedge sys_clk);
     wr_data = wr_data + 1;
    end
 
    // Wait for write end or observe behavior
    wait (wr_end);
    wr_req       = 0;
    
     @(posedge uut.ar_req);
     @(posedge uut.ar_end);
     @(posedge sys_clk);
     $finish;
  end
 
endmodule