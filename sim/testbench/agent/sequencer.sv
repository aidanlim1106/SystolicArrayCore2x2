`ifndef TPU_SEQUENCER_SV
`define TPU_SEQUENCER_SV

class tpu_sequencer extends uvm_sequencer #(tpu_seq_item);
    `uvm_component_utils(tpu_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass

`endif