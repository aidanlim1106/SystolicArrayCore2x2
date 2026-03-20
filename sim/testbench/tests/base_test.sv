`ifndef TPU_BASE_TEST_SV
`define TPU_BASE_TEST_SV

class tpu_base_test extends uvm_test;
    `uvm_component_utils(tpu_base_test)

    tpu_env env;
    virtual tpu_if vif;

    function new(string name = "tpu_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = tpu_env::type_id::create("env", this);
        if (!uvm_config_db#(virtual tpu_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("TEST_NOVIF", "Virtual interface not found in uvm_test_top")
        end
        uvm_config_db#(virtual tpu_if)::set(this, "env.agent.*", "vif", vif);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.phase_done.set_drain_time(this, 50ns);
    endtask
endclass

`endif