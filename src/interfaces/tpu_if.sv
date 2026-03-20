// TPU Core Interface for Verification
// Bundles all DUT signals together for the Testbench/UVM environment.

interface tpu_if #(parameter DATA_WIDTH = 8) (input logic clk, input logic rst_n);
    logic wr_en;
    logic [2:0] wr_addr;
    logic signed [DATA_WIDTH-1:0] wr_data;
    logic start;
    logic transpose_b;
    logic busy;
    logic done;
    logic signed [2*DATA_WIDTH-1:0] c00, c01, c10, c11;

    // driver clocking block
    clocking drv_cb @(posedge clk);
        default input #1step output #1ns;
        output wr_en, wr_addr, wr_data, start, transpose_b;
        input  busy, done, c00, c01, c10, c11;
    endclocking

    // monitor clocking block
    clocking mon_cb @(posedge clk);
        default input #1step output #1ns;
        input wr_en, wr_addr, wr_data, start, transpose_b;
        input busy, done, c00, c01, c10, c11;
    endclocking

    modport DRIVER  (clocking drv_cb, input clk, rst_n);
    modport MONITOR (clocking mon_cb, input clk, rst_n);

endinterface