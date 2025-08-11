module sdram_load_mode_register(
    input wire sys_clk,       // System clock
    input wire sys_rst_n,     // Active-low reset
    input wire sdram_init,
    input wire mode_reg_en,   // Mode Register enable signal
    input reg [11:0] mode_reg_val, // Mode Register Input Value 

    output reg [3:0] sdram_cmd, // SDRAM command bus
    output reg [1:0] sdram_ba,
    output reg [11:0] sdram_addr,
    output reg mode_reg_done  // Indicates Mode Register exit complete
);
    // ----------------------------------------------------
    // SDRAM Command Definitions
    // ----------------------------------------------------
    parameter CMD_PRECHARGE  = 4'b0010; // Precharge Command
    parameter CMD_LOAD_MODE  = 4'b0000; // Load Mode Register Command
    parameter CMD_NOP        = 4'b0111; // No Operation (NOP)
    
    // ----------------------------------------------------
    // FSM State Encoding
    // ----------------------------------------------------
    parameter IDLE       = 3'd0, // Initial state
              PRECHARGE  = 3'd1, // Precharge state
              WAIT_TRP   = 3'd2, // Precharge wait state
              LOAD_MODE  = 3'd3, // Load Mode Register state
              WAIT_TMRD  = 3'd4, // Load Mode Register wait state
              EXIT       = 3'd5; // Load Mode Register complete state

    // ----------------------------------------------------
    // SDRAM Timing Constraints
    // ----------------------------------------------------
    parameter TRP_COUNT   = 3'd2; // Precharge wait cycles
    parameter TMRD_COUNT  = 3'd2; // Mode Register Set wait cycles

    reg [2:0]  fsm_state;  // Load Mode Register state variable
    reg [2:0]  trp_count;
    reg [3:0]  tmrd_count;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            sdram_cmd  <= CMD_NOP;
            sdram_ba   <= 2'b11;
            sdram_addr <= 12'hfff;

            mode_reg_done <= 1'b0;

            trp_count  <= 0;
            tmrd_count <= 0;

            fsm_state   <= IDLE;
        end 
        else begin
            case (fsm_state)

                IDLE: begin
                    sdram_cmd  <= CMD_NOP;
                    sdram_ba   <= 2'b11;
                    sdram_addr <= 12'hfff;
    
                    trp_count  <= 0;
                    tmrd_count <= 0;
                    
                    if (mode_reg_en && sdram_init) begin
                        fsm_state <= PRECHARGE; // Ensure all banks are idle before Load Mode Register Command
                    end
                end
 
                PRECHARGE: begin
                    sdram_cmd  <= CMD_PRECHARGE; // Issue Precharge Command
                    sdram_ba   <= 2'b11;
                    sdram_addr <= 12'hfff;

                    mode_reg_done <= 1'b0;

                    fsm_state <= WAIT_TRP;
                end
                
                WAIT_TRP: begin 
                    sdram_cmd  <= CMD_NOP; // Issue Precharge Command
                    sdram_ba   <= 2'b11;
                    sdram_addr <= 12'hfff;

                    if (trp_count < TRP_COUNT) begin
                        trp_count <= trp_count + 1;
                        fsm_state <= WAIT_TRP;
                    end 
                    else begin
                       trp_count  <= 0;
                       fsm_state  <= LOAD_MODE;  
                    end
                end
                
                LOAD_MODE: begin
                    sdram_cmd  <= CMD_LOAD_MODE; 
                    sdram_ba   <= 2'b11;    
                    sdram_addr <= mode_reg_val; // Mode register config: burst length, CAS latency etc.
                    fsm_state  <= WAIT_TMRD;
                end
                
                WAIT_TMRD: begin 
                    sdram_cmd  <= CMD_NOP;
                    sdram_ba   <= 2'b11;
                    sdram_addr <= 12'hfff;

                    if (tmrd_count < TMRD_COUNT) begin
                       tmrd_count  <= tmrd_count + 1;
                       fsm_state   <= WAIT_TMRD;
                    end
                    else  begin
                       tmrd_count <= 0;
                       fsm_state  <= EXIT;  
                    end
                end
 
                EXIT: begin
                    sdram_cmd  <= CMD_NOP;
                    sdram_ba   <= 2'b11;
                    sdram_addr <= 12'hfff;

                    mode_reg_done <= 1'b1;

                    fsm_state <= IDLE;
                end
 
                default: fsm_state <= IDLE;
 
            endcase
        end
    end

endmodule