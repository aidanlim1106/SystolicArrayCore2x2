// Basys3 FPGA Wrapper for Systolic Core

module basys3_wrapper (
    input clk,  // 100 MHz
    input [15:0] sw,   // 16 slide switches
    input btnC, // Center button
    input btnU, // Up button
    output logic [15:0] led   // 16 LEDs above switches
);

    logic rst_n;
    assign rst_n = ~btnU;

// edge detector to create a single cycle pulse when the button is first pressed.
    logic btnC_sync1, btnC_sync2;
    logic start_pulse;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btnC_sync1 <= 1'b0;
            btnC_sync2 <= 1'b0;
        end else begin
            btnC_sync1 <= btnC;
            btnC_sync2 <= btnC_sync1;
        end
    end

    assign start_pulse = btnC_sync1 & ~btnC_sync2;
    logic busy, done;
    logic signed [15:0] c00, c01, c10, c11;

    systolic_core #(
        .DATA_WIDTH(8)
    ) u_core (
        .clk (clk),
        .rst_n (rst_n),
        .wr_en (sw[11]),
        .wr_addr (sw[10:8]),
        .wr_data (sw[7:0]),
        .transpose_b_en (sw[12]),
        .start (start_pulse),
        .busy (busy),
        .done (done),
        .c00 (c00),
        .c01 (c01),
        .c10  (c10),
        .c11 (c11)
    );

    logic [15:0] selected_result;

    // use sw to choose which result to display
    always_comb begin
        case (sw[15:14])
            2'b00: selected_result = c00;
            2'b01: selected_result = c01;
            2'b10: selected_result = c10;
            2'b11: selected_result = c11;
        endcase
    end

    assign led[15]   = done;
    assign led[14]   = busy;
    assign led[13:0] = selected_result[13:0];

endmodule