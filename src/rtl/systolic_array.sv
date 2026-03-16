// 2x2 Systolic Array

//     A enters from the LEFT  (west edge):   a_row0 → PE00 → PE01
//                                            a_row1 → PE10 → PE11
//     B enters from the TOP   (north edge):  b_col0 → PE00 → PE10
//                                            b_col1 → PE01 → PE11

module systolic_array #(
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic rst_n,
    input logic clear00,
    input logic clear01,
    input logic clear01,
    input logic clear11,
    // A row inputs
    input logic signed [DATA_WIDTH-1:0] a_row0,
    input logic signed [DATA_WIDTH-1:0] a_row1,
    // B row inputs
    input logic signed [DATA_WIDTH-1:0] b_col0,
    input logic signed [DATA_WIDTH-1:0] b_col1,
    // outputs
    output logic signed [2*DATA_WIDTH-1:0] c00,
    output logic signed [2*DATA_WIDTH-1:0] c01,
    output logic signed [2*DATA_WIDTH-1:0] c10,
    output logic signed [2*DATA_WIDTH-1:0] c11,
);

    logic signed [DATA_WIDTH-1:0] a_pe00_to_pe01;
    logic signed [DATA_WIDTH-1:0] a_pe10_to_pe11;
    logic signed [DATA_WIDTH-1:0] b_pe00_to_pe10;
    logic signed [DATA_WIDTH-1:0] b_pe01_to_pe11;

    logic signed [DATA_WIDTH-1:0] a_pe01_unused;
    logic signed [DATA_WIDTH-1:0] a_pe11_unused;
    logic signed [DATA_WIDTH-1:0] b_pe10_unused;
    logic signed [DATA_WIDTH-1:0] b_pe11_unused;

    // PE00 (Top left)
    processing_element #(.DATA_WIDTH(DATA_WIDTH)) pe00 (
        .clk    (clk),
        .rst_n  (rst_n),
        .clear  (clear00),
        .a_in   (a_row0),      
        .b_in   (b_col0),          
        .a_out  (a_pe00_to_pe01), 
        .b_out  (b_pe00_to_pe10), 
        .c_out  (c00)
    );

    // PE01 (Top right)
    processing_element #(.DATA_WIDTH(DATA_WIDTH)) pe01 (
        .clk    (clk),
        .rst_n  (rst_n),
        .clear  (clear01),
        .a_in   (a_pe00_to_pe01),      
        .b_in   (b_col1),          
        .a_out  (a_pe01_unused), 
        .b_out  (b_pe01_to_pe11), 
        .c_out  (c01)
    );

    // PE10 (Bottom left)
    processing_element #(.DATA_WIDTH(DATA_WIDTH)) pe10 (
        .clk    (clk),
        .rst_n  (rst_n),
        .clear  (clear10),
        .a_in   (a_row1),          
        .b_in   (b_pe00_to_pe10),  
        .a_out  (a_pe10_to_pe11),
        .b_out  (b_pe10_unused),  
        .c_out  (c10)
    );

    // PE11 (Bottom right)
    processing_element #(.DATA_WIDTH(DATA_WIDTH)) pe11 (
        .clk    (clk),
        .rst_n  (rst_n),
        .clear  (clear11),
        .a_in   (a_pe10_to_pe11),
        .b_in   (b_pe01_to_pe11),  
        .a_out  (a_pe11_unused),  
        .b_out  (b_pe11_unused),  
        .c_out  (c11)
    );

endmodule