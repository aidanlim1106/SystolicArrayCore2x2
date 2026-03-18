// Memory management unit - wavefront scheduler

// 1. Feeds correct A/B values to array edges each cycle
// 2. Assert PE specific clear pulses
// 3. Counting through compute and flush cycles
// 4. Signaling done when all PEs finished

module mmu #(
    parameter DATA_WIDTH = 8
)(
    input clk,
    input rst_n,
    input start,
    input signed [DATA_WIDTH-1:0] a00, a01, a10, a11,
    input signed [DATA_WIDTH-1:0] b00, b01, b10, b11,
    output logic signed [DATA_WIDTH-1:0] a_row0,  
    output logic signed [DATA_WIDTH-1:0] a_row1,   
    output logic signed [DATA_WIDTH-1:0] b_col0,   
    output logic signed [DATA_WIDTH-1:0] b_col1,  
    output logic clear00,
    output logic clear01,
    output logic clear10,
    output logic clear11,
    output logic busy,
    output logic done
);

    typedef enum logic [1:0] {
        S_IDLE = 2'b00,
        S_BUSY = 2'b01,
        S_DONE = 2'b10
    } state_t;

    state_t state, next_state;

    // 2 feed, 2 flush
    localparam MAXCYCLES = 4;
    localparam CTR_WIDTH = $clog2(MAXCYCLES + 1);
    logic [CTR_WIDTH-1:0] cycle_ctr;

    // state register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
        end else begin
            state <= next_state;
        end
    end

    // next state logic
    always_comb begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (start) begin
                    next_state = S_BUSY;
                end
            end
            S_BUSY: begin
                if (cycle_ctr == MAXCYCLES - 1) begin
                    next_state = S_DONE;
                end
            end
            S_DONE: begin
                next_state = S_IDLE;
            end
            default: next_state = S_IDLE;
        endcase
    end

    // cycle logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_ctr <= '0;
        end else if (state == S_BUSY) begin
            cycle_ctr <= cycle_ctr + 1;
        end else begin
            cycle_ctr <= '0;
        end
    end

    assign busy = (state == S_BUSY);
    assign done = (state == S_DONE);

    // feed operands
    always_comb begin
        a_row0 = '0;
        a_row1 = '0;
        b_col0 = '0;
        b_col1 = '0;

        if (state == S_BUSY) begin
            case (cycle_ctr)
                0: begin
                    a_row0 = a00;    // PE00 gets a00
                    a_row1 = '0;     // PE10 not ready yet
                    b_col0 = b00;    // PE00 gets b00
                    b_col1 = '0;     // PE01 not ready yet
                end
                1: begin
                    a_row0 = a01;    // PE00 gets a01 (second product)
                    a_row1 = a10;    // PE10 gets a10 (first product)
                    b_col0 = b10;    // PE00 gets b10 (second product)
                    b_col1 = b01;    // PE01 gets b01 (first product)
                end
                default: begin
                    a_row0 = '0;
                    a_row1 = a11;
                    b_col0 = '0;
                    b_col1 = b11;
                end
            endcase
        end
    end

    always_comb begin
        clear00 = 1'b0;
        clear01 = 1'b0;
        clear10 = 1'b0;
        clear11 = 1'b0;

        if (state == S_BUSY) begin
            case (cycle_ctr)
                0: clear00 = 1'b1;
                1: begin
                    clear01 = 1'b1;
                    clear10 = 1'b1;
                end
                2: clear11 = 1'b1;
                default: ; // no clears during final flush
            endcase
        end
    end

endmodule