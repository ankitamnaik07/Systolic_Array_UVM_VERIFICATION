class environment extends uvm_env;


`uvm_component_utils(environment)

agent agt;
scoreboard scb;
systolic_coverage cov;

function new(string name = "environment",
uvm_component parent = null);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);

super.build_phase(phase);

agt = agent::type_id::create("agt", this);
scb = scoreboard::type_id::create("scb", this);
cov = systolic_coverage::type_id::create("cov", this);

endfunction

function void connect_phase(uvm_phase phase);

super.connect_phase(phase);

// Monitor to scoreboard
agt.mon.mon_port.connect(scb.mon_fifo.analysis_export);

// Monitor to coverage subscriber
agt.mon.mon_port.connect(cov.analysis_export);

endfunction

endclass
