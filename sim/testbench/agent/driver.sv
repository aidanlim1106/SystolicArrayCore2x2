`ifndef TPU_DRIVER_SV
`define TPU_DRIVER_SV

class tpu_driver extends uvm_driver #(tpu_seq_item);
    `uvm_component_utils(tpu_driver)

    virtual tpu_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual tpu_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"})
        end
    endfunction

    task run_phase(uvm_phase phase);
        vif.wr_en       <= 0;
        vif.start       <= 0;
        vif.transpose_b <= 0;
        wait(vif.rst_n);

        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask

    task write_mem(logic [2:0] addr, logic signed [7:0] data);
        @(posedge vif.clk);
        vif.wr_en   <= 1'b1;
        vif.wr_addr <= addr;
        vif.wr_data <= data;
    endtask

    task drive_transaction(tpu_seq_item req);
        write_mem(3'd0, req.a[0][0]);
        write_mem(3'd1, req.a[0][1]);
        write_mem(3'd2, req.a[1][0]);
        write_mem(3'd3, req.a[1][1]);

        write_mem(3'd4, req.b[0][0]);
        write_mem(3'd5, req.b[0][1]);
        write_mem(3'd6, req.b[1][0]);
        write_mem(3'd7, req.b[1][1]);

        @(posedge vif.clk);
        vif.wr_en <= 1'b0;

        vif.transpose_b <= req.transpose_b;
        vif.start       <= 1'b1;
        @(posedge vif.clk);
        vif.start       <= 1'b0;

        wait(vif.done);
        @(posedge vif.clk);
    endtask
endclass

`endif