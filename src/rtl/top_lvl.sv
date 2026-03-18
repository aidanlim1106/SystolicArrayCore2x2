// Top level

// Usage:   
//   1. Write 8 operands (a00,a01,a10,a11,b00,b01,b10,b11) via wr_en/wr_addr/wr_data
//   2. Set transpose_b_en if desired
//   3. Pulse start
//   4. Wait for done
//   5. Read c00, c01, c10, c11

module systolic_core #(
    parameter DATA_WIDTH = 8
)(
    input clk,
    input rst_n,
    input  wr_en,
    input  start,
    input  transpose_b_en,
    output logic busy,
    output logic done,
    input  logic [2:0] wr_addr,   
    input  logic signed [DATA_WIDTH-1:0] wr_data,
    output logic signed [2*DATA_WIDTH-1:0] c00,
    output logic signed [2*DATA_WIDTH-1:0] c01,
    output logic signed [2*DATA_WIDTH-1:0] c10,
    output logic signed [2*DATA_WIDTH-1:0] c11
);

    logic signed [DATA_WIDTH-1:0] mem_a00, mem_a01, mem_a10, mem_a11;
    logic signed [DATA_WIDTH-1:0] mem_b00, mem_b01, mem_b10, mem_b11;

    logic signed [DATA_WIDTH-1:0] sa_a_row0, sa_a_row1;
    logic signed [DATA_WIDTH-1:0] sa_b_col0, sa_b_col1;
    logic sa_clear00, sa_clear01, sa_clear10, sa_clear11;

    logic signed [2*DATA_WIDTH-1:0] sa_c00, sa_c01, sa_c10, sa_c11;

    logic mmu_busy;
    logic mmu_done;

    memory #(
        .DATA_WIDTH (DATA_WIDTH)
    ) u_memory (
        .clk (clk),
        .rst_n (rst_n),
        .wr_en (wr_en),
        .wr_addr (wr_addr),
        .wr_data (wr_data),
        .transpose_b_en (transpose_b_en),
        .a00 (mem_a00),
        .a01 (mem_a01),
        .a10 (mem_a10),
        .a11 (mem_a11),
        .b00 (mem_b00),
        .b01 (mem_b01),
        .b10 (mem_b10),
        .b11 (mem_b11)
    );

    mmu #(
        .DATA_WIDTH (DATA_WIDTH)
    ) u_mmu (
        .clk (clk),
        .rst_n (rst_n),
        .start (start),
        .busy (mmu_busy),
        .done (mmu_done),
        .a00 (mem_a00),
        .a01 (mem_a01),
        .a10 (mem_a10),
        .a11 (mem_a11),
        .b00 (mem_b00),
        .b01 (mem_b01),
        .b10 (mem_b10),
        .b11 (mem_b11),
        .a_row0 (sa_a_row0),
        .a_row1 (sa_a_row1),
        .b_col0 (sa_b_col0),
        .b_col1 (sa_b_col1),
        .clear00 (sa_clear00),
        .clear01 (sa_clear01),
        .clear10 (sa_clear10),
        .clear11 (sa_clear11)
    );

    systolic_array #(
        .DATA_WIDTH (DATA_WIDTH)
    ) u_systolic_array (
        .clk (clk),
        .rst_n (rst_n),
        .clear00 (sa_clear00),
        .clear01 (sa_clear01),
        .clear10 (sa_clear10),
        .clear11 (sa_clear11),
        .a_row0 (sa_a_row0),
        .a_row1 (sa_a_row1),
        .b_col0 (sa_b_col0),
        .b_col1 (sa_b_col1),
        .c00 (sa_c00),
        .c01 (sa_c01),
        .c10 (sa_c10),
        .c11 (sa_c11)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            c00 <= '0;
            c01 <= '0;
            c10 <= '0;
            c11 <= '0;
        end else if (mmu_done) begin
            c00 <= sa_c00;
            c01 <= sa_c01;
            c10 <= sa_c10;
            c11 <= sa_c11;
        end
    end

    assign busy = mmu_busy;
    assign done = mmu_done;

endmodule