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
 
module sdram_top_struct (
    input  wire         sys_clk,
    input  wire         sys_rst_n,
    input  wire         wr_req,
    output  wire        wr_end,
    input  wire [24:0]  wr_addr,
    input  wire [15:0]  wr_data,
    input  wire [7:0]   wr_burst_len,
    input  wire         wr_dqm,
 
    output wire busy,
    output wire err,
    output wire new_data,
    output wire [15:0] wr_datao,
    output wire [11:0] addro,
    output wire [1:0]  bao,
    output wire [3:0]  cmdo
);
 
    // Internal wires for interconnecting modules
 
 
    wire        wr_en;
    wire [11:0] wr_addro;
    wire [1:0]  wr_bao;
    wire [3:0]  wr_cmdo;
    wire        wr_trans_err;
 
    wire        ar_en;
    wire        ar_req;
    wire        ar_end;
    wire [11:0] ar_addro;
    wire [1:0]  ar_bao;
    wire [3:0]  ar_cmdo;
 
    wire        start_auto_ref;
    wire        wr_busy;
    wire        wr_bcomplete;
    wire [3:0]  wr_cmd_out;
    wire [1:0]  wr_ba_out;
    wire [11:0] wr_addr_out;
    wire [15:0] wr_data_out;
    wire        wr_dqm_out;
 
    // Initialization Module
    wire        init_done;
    wire [3:0]  init_cmdo;
    wire [1:0]  init_bao;
    wire [11:0] init_addro;
    
    sdram_init u_sdram_init (
        .sys_clk    (sys_clk),
        .sys_rst_n  (sys_rst_n),
        .init_cmd   (init_cmdo),
        .init_ba    (init_bao),
        .init_addr  (init_addro),
        .init_done  (init_done)
    );
 
    // Controller Module
    wire wr_wait;
    controller u_controller (
        .sys_clk      (sys_clk),
        .sys_rst_n    (sys_rst_n),
        .init_done    (init_done),
        .init_addro   (init_addro),
        .init_bao     (init_bao),
        .init_cmdo    (init_cmdo),
 
        .wr_req       (wr_req),
        .wr_end       (wr_end),
        .wr_en        (wr_en),
        .wr_wait      (wr_wait),
        .wr_addro     (wr_addro),
        .wr_bao       (wr_bao),
        .wr_cmdo      (wr_cmdo),
 
        .ar_req       (ar_req),
        .ar_end       (ar_end),
        .ar_en        (ar_en),
        .ar_addro     (ar_addro),
        .ar_bao       (ar_bao),
        .ar_cmdo      (ar_cmdo),
 
        .addro        (addro), 
        .bao          (bao),
        .cmdo         (cmdo),
        .busy         (busy)
    );
 
    // Auto-refresh Module
    sdram_ar u_sdram_ar (
        .sys_clk   (sys_clk),
        .sys_rst_n (sys_rst_n),
        .init_done (init_done),
        .ar_en     (ar_en),
        .ar_req    (ar_req),
        .ar_end    (ar_end),            // Already connected to top input
        .ar_cmdo   (ar_cmdo),
        .ar_bao    (ar_bao),
        .ar_addro  (ar_addro)
    );
 
 
       sdram_write u_sdram_write (
        .sys_clk      (sys_clk),
        .sys_rst_n    (sys_rst_n),
        .init_done    (init_done),
        .wr_en        (wr_en),
        .wr_addri     (wr_addr),
        .wr_din       (wr_data),
        .wr_blength   (wr_burst_len),
        .wr_dqm_in    (wr_dqm),
        .wr_wait      (wr_wait), // auto-refresh wait request input
 
        .apply_data   (new_data),
        .wr_end       (wr_end),
        .wr_cmd       (wr_cmdo),
        .wr_ba        (wr_bao),
        .wr_addro     (wr_addro),
        .wr_dqm_out   (wr_dqm_out),
        .data_written (wr_datao),
        .trans_err    (err)
    );
 
endmodule