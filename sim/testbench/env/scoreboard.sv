`ifndef TPU_SCOREBOARD_SV
`define TPU_SCOREBOARD_SV

class tpu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(tpu_scoreboard)
    uvm_analysis_imp #(tpu_seq_item, tpu_scoreboard) ap_imp;
    int total_txns = 0;
    int passed     = 0;
    int failed     = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
    endfunction

    virtual function void write(tpu_seq_item item);
        logic signed [7:0]  b_eff[2][2];
        logic signed [15:0] exp_c[2][2];
        bit match = 1;

        total_txns++;

        b_eff[0][0] = item.b[0][0];
        b_eff[1][1] = item.b[1][1];
        if (item.transpose_b) begin
            b_eff[0][1] = item.b[1][0]; 
            b_eff[1][0] = item.b[0][1]; 
        end else begin
            b_eff[0][1] = item.b[0][1];
            b_eff[1][0] = item.b[1][0];
        end

        //dot products
        exp_c[0][0] = (item.a[0][0] * b_eff[0][0]) + (item.a[0][1] * b_eff[1][0]);
        exp_c[0][1] = (item.a[0][0] * b_eff[0][1]) + (item.a[0][1] * b_eff[1][1]);
        exp_c[1][0] = (item.a[1][0] * b_eff[0][0]) + (item.a[1][1] * b_eff[1][0]);
        exp_c[1][1] = (item.a[1][0] * b_eff[0][1]) + (item.a[1][1] * b_eff[1][1]);

        // 3. Verify
        for(int i=0; i<2; i++) begin
            for(int j=0; j<2; j++) begin
                if (exp_c[i][j] !== item.c_actual[i][j]) begin
                    match = 0;
                    `uvm_error("SCBD_FAIL", $sformatf("C[%0d][%0d] Mismatch! Exp: %0d | Act: %0d", 
                                            i, j, exp_c[i][j], item.c_actual[i][j]))
                end
            end
        end

        if (match) begin
            passed++;
            `uvm_info("SCBD_PASS", $sformatf("Match! %s", item.convert2string()), UVM_MEDIUM)
        end else begin
            failed++;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCBD_STATS", $sformatf("\n==================================\n  Total: %0d \n  Passed: %0d \n  Failed: %0d \n==================================", total_txns, passed, failed), UVM_NONE)
    endfunction
endclass

`endif