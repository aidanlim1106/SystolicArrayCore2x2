// Stores A and B matrices with optional B transpose

// 8 entry RF, each DATA_WIDTH bits wide
// write port: used by host (or UVM driver) to load ops
// read port: used by MMU to feed array every cycle

module memory #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input clk,
    input rst_n,
    input wr_en,
    input [ADDR_WIDTH-1:0] wr_addr,
    input signed [DATA_WIDTH-1:0] wr_data,
    input transpose_b_en,
    output logic signed [DATA_WIDTH-1:0] a00, a01, a10, a11,
    output logic signed [DATA_WIDTH-1:0] b00, b01, b10, b11
);

    logic signed [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < DEPTH; i++) begin
                mem[i] <= '0;
            end 
        end else if (wr_en) begin
            mem[wr_addr] <= wr_data;
        end
    end

    assign a00 = mem[0];
    assign a01 = mem[1];
    assign a10 = mem[2];
    assign a11 = mem[3];

    assign b00 = mem[4];                                  
    assign b01 = transpose_b_en ? mem[6] : mem[5];           
    assign b10 = transpose_b_en ? mem[5] : mem[6];      
    assign b11 = mem[7];  

endmodule