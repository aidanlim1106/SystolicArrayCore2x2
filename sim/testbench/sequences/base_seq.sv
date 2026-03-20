`ifndef TPU_BASE_SEQ_SV
`define TPU_BASE_SEQ_SV

class tpu_base_seq extends uvm_sequence #(tpu_seq_item);
    `uvm_object_utils(tpu_base_seq)

    function new(string name = "tpu_base_seq");
        super.new(name);
    endfunction
endclass

`endif