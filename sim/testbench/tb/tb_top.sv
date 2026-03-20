`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "tpu.include"
`include "../tests/tpu_base_test.sv"
`include "../tests/tpu_random_test.sv"

module tb_top;
    logic clk;
    logic rst_n;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #20 rst_n = 1;
    end

    tpu_if #(.DATA_WIDTH(8)) vif(.clk(clk), .rst_n(rst_n));

    systolic_core #(.DATA_WIDTH(8)) dut (
        .clk         (vif.clk),
        .rst_n       (vif.rst_n),
        .wr_en       (vif.wr_en),
        .wr_addr     (vif.wr_addr),
        .wr_data     (vif.wr_data),
        .transpose_b (vif.transpose_b),
        .start       (vif.start),
        .busy        (vif.busy),
        .done        (vif.done),
        .c00         (vif.c00),
        .c01         (vif.c01),
        .c10         (vif.c10),
        .c11         (vif.c11)
    );

    initial begin
        uvm_config_db#(virtual tpu_if)::set(null, "uvm_test_top", "vif", vif);
        $dumpfile("tpu_waves.vcd");
        $dumpvars(0, tb_top);
        run_test();
    end

endmodule