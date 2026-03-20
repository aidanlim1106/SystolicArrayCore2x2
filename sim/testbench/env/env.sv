`ifndef TPU_ENV_SV
`define TPU_ENV_SV

class tpu_env extends uvm_env;
    `uvm_component_utils(tpu_env)

    tpu_agent      agent;
    tpu_scoreboard scbd;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = tpu_agent::type_id::create("agent", this);
        scbd  = tpu_scoreboard::type_id::create("scbd", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.ap.connect(scbd.ap_imp);
    endfunction
endclass

`endif