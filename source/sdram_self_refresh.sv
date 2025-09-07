module sdram_self_refresh(
    input wire sys_clk,       // System clock
    input wire sys_rst_n,     // Active-low reset
    input wire sdram_init,
    input wire self_ref_en,   // Self-refresh enable signal

    output reg sdram_cke,     // SDRAM clock enable
    output reg [3:0] sdram_cmd, // SDRAM command bus
    output reg [1:0] sdram_ba,
    output reg [11:0] sdram_addr,
    output reg self_ref_done  // Indicates self-refresh exit complete
);
 
    // --------------------------------------------------
    // SDRAM Command Encodings
    // --------------------------------------------------
    parameter CMD_PRECHARGE  = 4'b0010; // Precharge Command
    parameter CMD_AUTO_REF   = 4'b0001; // Auto-Refresh Command
    parameter CMD_NOP        = 4'b0111; // No Operation (NOP)
 
    // --------------------------------------------------
    // FSM State Encodings
    // --------------------------------------------------
    parameter IDLE         = 4'b0000; // Idle state
    parameter PRECHARGE    = 4'b0001; // Precharge all banks before Self-Refresh
    parameter ENTRY        = 4'b0010; // Enter Self-Refresh mode
    parameter WAIT         = 4'b0011; // Stay in Self-Refresh mode
    parameter EXIT         = 4'b0100; // Exit Self-Refresh mode
    parameter POST_REFRESH = 4'b0101; // Perform 4096 Auto-Refresh cycles
    parameter WAIT_TRP     = 4'b0110; // Wait for tRP timing
    parameter WAIT_TRFC1   = 4'b0111; // First refresh wait state
    parameter WAIT_TRFC2   = 4'b1000; // Second refresh wait state (still within 4-bit range)
  
    // --------------------------------------------------
    // Internal Registers and Wires
    // --------------------------------------------------
    reg [3:0]  current_state;  // Self-Refresh state variable
    reg [12:0] ref_count; // Counter for 4096 Auto-Refresh cycles
    reg [3:0]  tXSR_count; // Counter for tXSR timing requirement
    reg [2:0]  trp_count;
    reg [3:0]  trfc_count;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            // Internal state and pins
            current_state   <= IDLE;
            self_ref_done <= 1'b0;
            ref_count <= 13'd0;
            tXSR_count <= 4'd0;
            trp_count  <= 0;
            trfc_count <= 0;

            // Output Pins
            sdram_cke  <= 1'b1;  // Default: CKE enabled
            sdram_cmd  <= CMD_NOP;
            sdram_ba   <= 2'b11;
            sdram_addr <= 12'hfff;
        end 
        else begin
            case (current_state)
                // **IDLE: Wait for Self-Refresh Enable**
                IDLE: begin
                    self_ref_done <= 1'b0;
                    ref_count <= 13'd0;
                    tXSR_count <= 4'd0;
                    trp_count  <= 0;
                    trfc_count <= 0;
                    
                    if (self_ref_en && sdram_init) begin
                        current_state <= PRECHARGE; // Ensure all banks are idle before self-refresh
                    end
                end
 
                // **PRECHARGE: Close all active rows to ensure banks are idle**
                PRECHARGE: begin
                    sdram_cmd <= CMD_PRECHARGE; // Issue Precharge Command

                    current_state <= WAIT_TRP;
                end
                
                WAIT_TRP: begin 
                    sdram_cmd <= CMD_NOP; // Issue Precharge Command
                    // trp is 2 cycles
                    if (trp_count < 2) begin
                        trp_count <= trp_count + 1;
                        current_state <= WAIT_TRP;
                    end else begin
                       trp_count <= 0;
                       current_state  <= ENTRY;  
                    end
                end

                // **ENTRY: Send Auto-Refresh Command and Set CKE Low**
                ENTRY: begin
                    sdram_cke <= 1'b0;  // Disable clock
                    sdram_cmd <= CMD_AUTO_REF; // Send Auto-Refresh command

                    current_state <= WAIT_TRFC1;
                end
                
                WAIT_TRFC1: begin 
                    sdram_cmd <= CMD_NOP;
                    // trfc is 7 cycles
                    if (trfc_count < 8) begin
                       trfc_count <= trfc_count + 1;
                       current_state <= WAIT_TRFC1;
                    end else begin
                       trfc_count <= 0;
                       current_state  <= WAIT;  
                    end
                end
 
                // **WAIT: Remain in Self-Refresh Mode**
                WAIT: begin
                    sdram_cke <= 1'b0; // Keep CKE low
                    sdram_cmd <= CMD_NOP;

                    if (!self_ref_en) begin
                        current_state <= POST_REFRESH; // Exit when requested
                    end
                end
 
 
                // **POST-REFRESH: Perform 4096 Auto-Refresh Commands**
                POST_REFRESH: begin
                    sdram_cke <= 1'b1;
                    // There are 4096 rows, refresh all rows
                    if (ref_count < 13'd4096) begin
                        sdram_cmd <= CMD_AUTO_REF; // Perform Auto-Refresh cycle
                        ref_count <= ref_count + 1;
                        current_state <= WAIT_TRFC2;
                    end else begin
                        ref_count <= 13'd0;
                        current_state <= EXIT; 
                    end
                end
                
                WAIT_TRFC2: begin 
                    sdram_cmd <= CMD_NOP;
                    // trfc has 7 cycles
                    if (trfc_count < 8) begin
                       trfc_count <= trfc_count + 1;
                       current_state <= WAIT_TRFC2;
                    end else begin
                       trfc_count <= 0;
                       current_state <= POST_REFRESH;  
                    end
                end
            
               EXIT: begin
                    sdram_cke <= 1'b1; // Enable CKE
                    sdram_cmd <= CMD_NOP;
                    // txsr has 7 cycles
                    if (tXSR_count < 4'd8) begin
                        tXSR_count <= tXSR_count + 1;
                        current_state <= EXIT; 
                    end else begin
                        tXSR_count <= 4'd0;
                        current_state <= IDLE;
                        
                        self_ref_done <= 1'b1; // Indicate self-refresh is complete
                    end
                end
 
                default: current_state <= IDLE;
 
            endcase
        end
    end
endmodule
