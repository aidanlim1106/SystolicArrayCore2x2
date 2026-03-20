`ifndef TPU_SEQ_ITEM_SV
`define TPU_SEQ_ITEM_SV

class tpu_seq_item extends uvm_sequence_item;
    rand logic signed [7:0] a[2][2];
    rand logic signed [7:0] b[2][2];
    rand logic              transpose_b;

    logic signed [15:0]     c_actual[2][2];

    `uvm_object_utils_begin(tpu_seq_item)
        `uvm_field_int(transpose_b, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "tpu_seq_item");
        super.new(name);
    endfunction

    virtual function string convert2string();
        return $sformatf("Transpose: %0b | A: [[%0d,%0d],[%0d,%0d]] | B: [[%0d,%0d],[%0d,%0d]]", 
            transpose_b, a[0][0], a[0][1], a[1][0], a[1][1], b[0][0], b[0][1], b[1][0], b[1][1]);
    endfunction
endclass

`endif