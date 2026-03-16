// Memory management unit - wavefront scheduler

// 1. Feeds correct A/B values to array edges each cycle
// 2. Assert PE specific clear pulses
// 3. Counting through compute and flush cycles
// 4. Signaling done when all PEs finished

module mmu #(
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic busy,
    input logic done,
    input  logic signed [DATA_WIDTH-1:0]      a00, a01, a10, a11,
    input  logic signed [DATA_WIDTH-1:0]      b00, b01, b10, b11,
    output logic signed [DATA_WIDTH-1:0]      a_row0,  
    output logic signed [DATA_WIDTH-1:0]      a_row1,   
    output logic signed [DATA_WIDTH-1:0]      b_col0,   
    output logic signed [DATA_WIDTH-1:0]      b_col1,  
    output logic                              clear00,
    output logic                              clear01,
    output logic                              clear10,
    output logic                              clear11
)