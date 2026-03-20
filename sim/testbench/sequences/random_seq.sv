`ifndef TPU_RANDOM_SEQ_SV
`define TPU_RANDOM_SEQ_SV

class tpu_random_seq extends tpu_base_seq;
    `uvm_object_utils(tpu_random_seq)
    int num_txns = 500;

    function new(string name = "tpu_random_seq");
        super.new(name);
    endfunction

    task body();
        tpu_seq_item req;
        
        for(int i = 0; i < num_txns; i++) begin
            req = tpu_seq_item::type_id::create("req");
            start_item(req);
            
            if (!req.randomize()) begin
                `uvm_error("SEQ", "Randomization failed!")
            end
            finish_item(req);
        end
    endtask
endclass

`endif