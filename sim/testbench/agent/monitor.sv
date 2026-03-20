`ifndef TPU_MONITOR_SV
`define TPU_MONITOR_SV

class tpu_monitor extends uvm_monitor;
    `uvm_component_utils(tpu_monitor)

    virtual tpu_if vif;
    uvm_analysis_port #(tpu_seq_item) ap;
    logic signed [7:0] shadow_mem [8];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual tpu_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "Virtual interface not found in monitor")
        end
    endfunction

    task run_phase(uvm_phase phase);
        tpu_seq_item txn;
        
        forever begin
            @(posedge vif.clk);

            if (vif.wr_en) begin
                shadow_mem[vif.wr_addr] = vif.wr_data;
            end

            if (vif.start) begin
                txn = tpu_seq_item::type_id::create("txn");
                txn.transpose_b = vif.transpose_b;
                txn.a[0][0] = shadow_mem[0];
                txn.a[0][1] = shadow_mem[1];
                txn.a[1][0] = shadow_mem[2];
                txn.a[1][1] = shadow_mem[3];
                txn.b[0][0] = shadow_mem[4];
                txn.b[0][1] = shadow_mem[5];
                txn.b[1][0] = shadow_mem[6];
                txn.b[1][1] = shadow_mem[7];
                wait(vif.done);
                @(posedge vif.clk);
                txn.c_actual[0][0] = vif.c00;
                txn.c_actual[0][1] = vif.c01;
                txn.c_actual[1][0] = vif.c10;
                txn.c_actual[1][1] = vif.c11;
                ap.write(txn);
            end
        end
    endtask
endclass

`endif