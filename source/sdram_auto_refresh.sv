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
 
 
 
module sdram_ar (
    input  wire        sys_clk,       // System clock (100MHz)
    input  wire        sys_rst_n,     // Active-low reset
    input  wire        init_done,     // Initialization complete signal
    input  wire        ar_en,         // Auto-refresh enable
 
    output reg         ar_req,        // Auto-refresh request
    output reg         ar_end,        // Auto-refresh end signal
    output reg  [3:0]  ar_cmdo,       // SDRAM command during auto-refresh
    output reg  [1:0]  ar_bao,        // Bank address (fixed value)
    output reg  [11:0] ar_addro       // SDRAM address (fixed value)
);
 
    // --------------------------------------------------
    // Timing Parameters
    // --------------------------------------------------
    parameter CNT_REF_MAX  = 11'd1540;  // Refresh interval (~15.5us) for a single row
    parameter TRP_COUNT    = 3'd2;      // Precharge wait cycles
    parameter TRFC_COUNT   = 3'd7;      // Auto-refresh wait cycles
 
    // --------------------------------------------------
    // SDRAM Command Encodings
    // --------------------------------------------------
    parameter CMD_PRECHARGE    = 4'b0010;
    parameter CMD_AUTOREFRESH  = 4'b0001;
    parameter CMD_NOP          = 4'b0111;
 
    // --------------------------------------------------
    // FSM State Encodings
    // --------------------------------------------------
    parameter IDLE         = 3'b000;
    parameter PRECHARGE    = 3'b001;
    parameter WAIT_TRP     = 3'b011;
    parameter AUTOREFRESH  = 3'b010;
    parameter WAIT_TRFC    = 3'b100;
    parameter END          = 3'b101;
 
    // --------------------------------------------------
    // Internal Registers and Wires
    // --------------------------------------------------
    reg  [10:0] cnt_aref;           // Refresh interval counter
    reg  [2:0]  current_state;      // FSM current state
    reg  [2:0]  cnt_clk;            // Wait cycle counter
    reg         cnt_clk_rst;       // Counter reset flag
    reg  [1:0]  refresh_count;     // Number of refresh cycles
 
    wire trp_done;                 // Precharge wait complete flag
    wire trfc_done;                // Auto-refresh wait complete flag
    wire ack;                      // Acknowledge signal for refresh start
    wire aref_end;
 
    // --------------------------------------------------
    // Auto-refresh acknowledgment and end signal
    // --------------------------------------------------
    assign ack      = (current_state == PRECHARGE);
    assign aref_end = (current_state == END); 
 
    // --------------------------------------------------
    // Refresh Interval Counter
    // --------------------------------------------------
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            cnt_aref <= 11'd0;
        else if (cnt_aref >= CNT_REF_MAX)
            cnt_aref <= 11'd0;
        else if (init_done)
            cnt_aref <= cnt_aref + 1'b1; // start counter once init_done
    end
 
    // --------------------------------------------------
    // Generate Auto-Refresh Request
    // --------------------------------------------------
    // When the time has elasped generate an auto refresh request
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            ar_req <= 1'b0;
        else if (cnt_aref == (CNT_REF_MAX - 1))
            ar_req <= 1'b1;
        else if (ack) // Deassert when the arbitration acknowledges it
            ar_req <= 1'b0;
    end
 
    // --------------------------------------------------
    // Wait Cycle Counter
    // --------------------------------------------------
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            cnt_clk <= 3'd0;
        else if (cnt_clk_rst)
            cnt_clk <= 3'd0;
        else
            cnt_clk <= cnt_clk + 1'b1;
    end
 
    // --------------------------------------------------
    // Wait Completion Flags
    // --------------------------------------------------
    assign trp_done  = (current_state == WAIT_TRP  && cnt_clk == TRP_COUNT);
    assign trfc_done = (current_state == WAIT_TRFC && cnt_clk == TRFC_COUNT);

    // --------------------------------------------------
    // FSM: Auto-Refresh Operation Control
    // --------------------------------------------------
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            current_state <= IDLE;
        else begin
            case (current_state)
                IDLE: begin
                    refresh_count <= 0;
                    if (ar_en && init_done)
                        current_state <= PRECHARGE;
                end
 
                PRECHARGE: begin
                    current_state <= WAIT_TRP;
                end
 
                WAIT_TRP: begin
                    if (trp_done)
                        current_state <= AUTOREFRESH;
                end
 
                AUTOREFRESH: begin
                    current_state <= WAIT_TRFC;
                end
 
                WAIT_TRFC: begin
                    /*
                    if (trfc_done)
                        current_state <= END;
                    else
                        current_state <= WAIT_TRFC;
                    */
                    
                    if (trfc_done) begin
                        if (refresh_count == 1'b1)  // After 2 refreshes (0 to 1)
                            current_state <= END;
                        else begin
                            current_state   <= AUTOREFRESH;
                            refresh_count <= refresh_count + 1;
                        end
                    end
                    else
                        current_state <= WAIT_TRFC;
                    
                end
 
                END: begin
                    current_state <= IDLE;
                end
 
                default: current_state <= IDLE;
            endcase
        end
    end
 
    // --------------------------------------------------
    // Counter Reset Logic Based on FSM State
    // --------------------------------------------------
    always @(*) begin
        case (current_state)
            IDLE,
            END:        cnt_clk_rst = 1'b1;
            WAIT_TRP:   cnt_clk_rst = trp_done;
            WAIT_TRFC:  cnt_clk_rst = trfc_done;
            default:    cnt_clk_rst = 1'b0;
        endcase
    end
 
    // --------------------------------------------------
    // SDRAM Command / Address / Bank Selection
    // --------------------------------------------------
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            ar_cmdo  <= CMD_NOP;
            ar_bao   <= 2'b11;
            ar_addro <= 12'hFFF;
            ar_end   <= 1'b0;
        end else begin
            case (current_state)
                IDLE,
                WAIT_TRP,
                WAIT_TRFC: begin
                    ar_cmdo  <= CMD_NOP;
                    ar_bao   <= 2'b11;
                    ar_addro <= 12'hFFF;
                    ar_end   <= 1'b0;
                end
 
                PRECHARGE: begin
                    ar_cmdo  <= CMD_PRECHARGE;
                    ar_bao   <= 2'b11;
                    ar_addro <= 12'hFFF;
                    ar_end   <= 1'b0;
                end
 
                AUTOREFRESH: begin
                    ar_cmdo  <= CMD_AUTOREFRESH;
                    ar_bao   <= 2'b11;
                    ar_addro <= 12'hFFF;
                    ar_end   <= 1'b0;
                end
 
                END: begin
                    ar_cmdo  <= CMD_NOP;
                    ar_bao   <= 2'b11;
                    ar_addro <= 12'hFFF;
                    ar_end   <= 1'b1;
                end
 
                default: begin
                    ar_cmdo  <= CMD_NOP;
                    ar_bao   <= 2'b11;
                    ar_addro <= 12'hFFF;
                end
            endcase
        end
    end
 
endmodule