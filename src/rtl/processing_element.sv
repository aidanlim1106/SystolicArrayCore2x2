// Signed MAC with systolic forwarding

// Each PE performs fresh accumulation on clear, and accumulates 
// and forwards:
//      a_in -> a_out (east, one cycle after)
//      b_in -> b_out (south, '')

module processing_element #(
    parameter DATA_WIDTH = 8
)(
    input logic     clk,
    input logic     rst_n,
    input logic     clear,
    input logic signed [DATA_WIDTH-1:0]  a_in,   // op_west
    input logic signed [DATA_WIDTH-1:0]  b_in,   // op_north
    output logic signed [DATA_WIDTH-1:0] a_out,  // forwarded_east
    output logic signed [DATA_WIDTH-1:0] b_out,  // forwarded_south
    output logic signed [2*DATA_WIDTH-1:0] c_out // accumulated result
);

    // internal accumulator to hold full MAC
    logic signed [2*DATA_WIDTH-1:0] c_reg;

    logic signed [2*DATA_WIDTH-1:0] product;
    assign product = a_in * b_in;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            c_reg <= '0;
            a_out <= '0;
            b_out <= '0;
        end else begin
            if (clear) begin
                c_reg <= product;
            end else begin
                c_reg <= c_reg + product;
            end
            a_out <= a_in;
            b_out <= b_in;
        end
    end

    assign c_out = c_reg;

endmodule