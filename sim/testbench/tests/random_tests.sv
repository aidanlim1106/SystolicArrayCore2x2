`ifndef TPU_RANDOM_TEST_SV
`define TPU_RANDOM_TEST_SV

class tpu_random_test extends tpu_base_test;
    `uvm_component_utils(tpu_random_test)

    function new(string name = "tpu_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        tpu_random_seq seq;
        seq = tpu_random_seq::type_id::create("seq");
        phase.raise_objection(this, "Starting random sequence");
        
        `uvm_info("TEST", "Executing Random Sequence...", UVM_LOW)
        seq.start(env.agent.sqr);
        phase.drop_objection(this, "Finished random sequence");
    endtask
endclass

`endif