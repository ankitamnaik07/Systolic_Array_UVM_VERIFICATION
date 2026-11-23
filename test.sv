class systolic_base_test extends uvm_test;
  `uvm_component_utils(systolic_base_test)

  environment env;

  function new(string name = "systolic_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = environment::type_id::create("env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass


class reset_idle_test extends systolic_base_test;
  `uvm_component_utils(reset_idle_test)

  function new(string name="reset_idle_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    reset_idle_seq seq;
    phase.raise_objection(this);
    seq = reset_idle_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class systolic_reset_fsm_test extends systolic_base_test;
  `uvm_component_utils(systolic_reset_fsm_test)

  function new(string name = "systolic_reset_fsm_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    systolic_reset_fsm_seq seq;

    phase.raise_objection(this, "Starting reset-in-every-FSM-state sequence");

    seq = systolic_reset_fsm_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);          // adjust to your hierarchy

    // Let the last probe read drain through the monitor and scoreboard
    #100ns;

    phase.drop_objection(this, "Reset sequence done");
  endtask
endclass

/*
class reset_state_test extends systolic_base_test;

  `uvm_component_utils(reset_state_test)

  function new(string name = "reset_state_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

task run_phase(uvm_phase phase);

    reset_state_seq seq;

    phase.raise_objection(this);

    seq = reset_state_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);

    phase.drop_objection(this);

  endtask

endclass
*/


class reset_abort_test extends systolic_base_test;
  `uvm_component_utils(reset_abort_test)

  function new(string name="reset_abort_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    reset_abort_seq seq;
    phase.raise_objection(this);
    seq = reset_abort_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class ena_check_test extends systolic_base_test;
  `uvm_component_utils(ena_check_test)

  function new(string name="ena_check_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    ena_check_seq seq;
    phase.raise_objection(this);
    seq = ena_check_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class matrix_load_test extends systolic_base_test;
  `uvm_component_utils(matrix_load_test)

  function new(string name="matrix_load_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    matrix_load_seq seq;
    phase.raise_objection(this);
    seq = matrix_load_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class done_load_test extends systolic_base_test;
  `uvm_component_utils(done_load_test)

  function new(string name="done_load_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    done_load_seq seq;
    phase.raise_objection(this);
    seq = done_load_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class matrix_reload_test extends systolic_base_test;
  `uvm_component_utils(matrix_reload_test)

  function new(string name="matrix_reload_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    matrix_reload_seq seq;
    phase.raise_objection(this);
    seq = matrix_reload_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class matrix_order_test extends systolic_base_test;
  `uvm_component_utils(matrix_order_test)

  function new(string name="matrix_order_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    matrix_order_seq seq;
    phase.raise_objection(this);
    seq = matrix_order_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class arithmetic_test extends systolic_base_test;
  `uvm_component_utils(arithmetic_test)

  function new(string name="arithmetic_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    arithmetic_seq seq;
    phase.raise_objection(this);
    seq = arithmetic_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class overflow_test extends systolic_base_test;
  `uvm_component_utils(overflow_test)

  function new(string name="overflow_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    overflow_seq seq;
    phase.raise_objection(this);
    seq = overflow_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class read_wrap_test extends systolic_base_test;
  `uvm_component_utils(read_wrap_test)

  function new(string name="read_wrap_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    read_wrap_seq seq;
    phase.raise_objection(this);
    seq = read_wrap_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class data_retain_test extends systolic_base_test;
  `uvm_component_utils(data_retain_test)

  function new(string name="data_retain_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    data_retain_seq seq;
    phase.raise_objection(this);
    seq = data_retain_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class random_test extends systolic_base_test;
  `uvm_component_utils(random_test)

  function new(string name="random_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    random_test_seq seq;
    phase.raise_objection(this);
    seq = random_test_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class priority_test extends systolic_base_test;
  `uvm_component_utils(priority_test)

  function new(string name="priority_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    priority_seq seq;
    phase.raise_objection(this);
    seq = priority_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class wb_start_test extends systolic_base_test;
  `uvm_component_utils(wb_start_test)

  function new(string name="wb_start_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    wb_start_seq seq;
    phase.raise_objection(this);
    seq = wb_start_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class invalid_req_test extends systolic_base_test;
  `uvm_component_utils(invalid_req_test)

  function new(string name="invalid_req_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    invalid_req_seq seq;
    phase.raise_objection(this);
    seq = invalid_req_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class load_length_test extends systolic_base_test;
  `uvm_component_utils(load_length_test)

  function new(string name="load_length_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    load_length_seq seq;
    phase.raise_objection(this);
    seq = load_length_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class back2back_test extends systolic_base_test;
  `uvm_component_utils(back2back_test)

  function new(string name="back2back_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    back2back_seq seq;
    phase.raise_objection(this);
    seq = back2back_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class upper_bits_test extends systolic_base_test;
  `uvm_component_utils(upper_bits_test)

  function new(string name="upper_bits_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    upper_bits_seq seq;
    phase.raise_objection(this);
    seq = upper_bits_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

class read_retain_test extends systolic_base_test;
  `uvm_component_utils(read_retain_test)

  function new(string name="read_retain_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    read_retain_seq seq;
    phase.raise_objection(this);
    seq = read_retain_seq::type_id::create("seq");
    seq.start(env.agt.sqcr);
    phase.drop_objection(this);
  endtask
endclass

