`ifndef TPU_SIMPLE_SEQ_SV
`define TPU_SIMPLE_SEQ_SV

class tpu_simple_seq extends tpu_base_seq;
    `uvm_object_utils(tpu_simple_seq)

    function new(string name = "tpu_simple_seq");
        super.new(name);
    endfunction

    task body();
        tpu_seq_item req;
        req = tpu_seq_item::type_id::create("req");

        start_item(req);
        req.a[0][0] = 5;  req.a[0][1] = -3;
        req.a[1][0] = 10; req.a[1][1] = 2;
        req.b[0][0] = 1;  req.b[0][1] = 0;
        req.b[1][0] = 0;  req.b[1][1] = 1;
        req.transpose_b = 0;
        finish_item(req);
    endtask
endclass

`endif