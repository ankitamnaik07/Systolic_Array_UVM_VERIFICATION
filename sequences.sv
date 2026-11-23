class systolic_base_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(systolic_base_seq)

  function new(string name = "systolic_base_seq");
    super.new(name);
  endfunction

  task apply_reset(int cycles = 2);
    req = seq_item::type_id::create("req");
    repeat(cycles) begin
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b0;uio_in == 8'h00; ui_in == 8'h00;}) else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
    start_item(req);
    assert(req.randomize() with {rst_n == 1'b1;uio_in == 8'h00; ui_in == 8'h00;}) else `uvm_error(get_type_name(), "rand failed");
    finish_item(req);
  endtask

  task idle_cycles(int cycles = 1);
    req = seq_item::type_id::create("req");
    repeat(cycles) begin
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b1;uio_in == 8'h00; ui_in == 8'h00;}) else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
  endtask

  task load_a(int cycles = 16);
    req = seq_item::type_id::create("req");
    repeat(cycles) begin
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b1;uio_in == 8'h01; ui_in[7:4] == 4'h0;}) else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
    idle_cycles(1);
  endtask

  task load_b(int cycles = 16);
    req = seq_item::type_id::create("req");
    repeat(cycles) begin
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b1; uio_in == 8'h02; ui_in[7:4] == 4'h0;}) else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
    idle_cycles(1);
  endtask

  task start_and_wait_done();
    req = seq_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {rst_n == 1'b1;uio_in == 8'h04; ui_in == 8'h00;}) else `uvm_error(get_type_name(), "rand failed");
    finish_item(req);
    idle_cycles(32);
  endtask

  task read_results(int cycles = 32);
    req = seq_item::type_id::create("req");
    repeat(cycles) begin
      start_item(req);
<<<<<<< HEAD
	    assert(req.randomize() with {rst_n == 1'b1;  uio_in == 8'h08; ui_in inside {[8'h01:8'h0F]};}) else `uvm_error(get_type_name(), "rand failed");
=======
	    assert(req.randomize() with {rst_n == 1'b1;  uio_in == 8'h08; ui_in=8'h0;}) else `uvm_error(get_type_name(), "rand failed");
>>>>>>> origin/main
      finish_item(req);
    end
    idle_cycles(1);
  endtask
endclass

class reset_idle_seq extends systolic_base_seq;
  `uvm_object_utils(reset_idle_seq)

  function new(string name = "reset_idle_seq");
    super.new(name);
  endfunction

  task body();
    apply_reset(3);
	  load_a(16);
	  load_b(16);
    start_and_wait_done();
    read_results(32);
  endtask
endclass



class systolic_reset_fsm_seq extends systolic_base_seq;
  `uvm_object_utils(systolic_reset_fsm_seq)

  typedef enum {ST_IDLE, ST_LOAD_A, ST_LOAD_B, ST_COMPUTE, ST_WB, ST_DONE, ST_READ} fsm_e;

  // Idle cycles after the START item before the reset item is driven.
  // START item = cycle 0, COMPUTE = cycles 1..6, WB = cycle 7 (first pass).
  // Tune against the waveform if the driver/DUT alignment is off by one.
  int compute_k = 2;
  int wb_k      = 6;

  function new(string name = "systolic_reset_fsm_seq");
    super.new(name);
  endfunction

  // Drive a fixed uio_in value for n cycles with random data nibble (ui_in[7:4] = 0)
  task drive(bit [7:0] uio, int n);
    req = seq_item::type_id::create("req");
    repeat (n) begin
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b1; uio_in == uio; ui_in[7:4] == 4'h0;})
        else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
  endtask

  task load_both_and_start();
    load_a();
    load_b();
    drive(8'h04, 1);              // START pulse, cycle 0
  endtask

  // After reset the FSM should be in IDLE: probe it from the pins
  task post_reset_probe();
    idle_cycles(2);
    drive(8'h08, 3);              // READ in IDLE must be ignored (DONE stays 0)
    idle_cycles(1);
    drive(8'h04, 1);              // START with no reload -> zero result
    idle_cycles(32);              // 29 cycles START->DONE, plus margin
    read_results(32);             // scoreboard expects all zeros
    idle_cycles(2);
  endtask

  task reset_in_state(fsm_e st);
    `uvm_info(get_type_name(), $sformatf("Applying reset in state %s", st.name()), UVM_LOW)

    apply_reset(2);               // known starting point
    idle_cycles(2);

    case (st)
      ST_IDLE:    idle_cycles(3);

      ST_LOAD_A:  drive(8'h01, 5);                    // mid-burst, strobe still high

      ST_LOAD_B:  begin load_a(); drive(8'h02, 7); end

      ST_COMPUTE: begin load_both_and_start(); idle_cycles(compute_k); end

      ST_WB:      begin load_both_and_start(); idle_cycles(wb_k); end

      ST_DONE:    begin load_both_and_start(); idle_cycles(31); end   // result ready

      ST_READ:    begin load_both_and_start(); idle_cycles(31); drive(8'h08, 10); end
    endcase

    apply_reset(2);               // reset in the target state (base task)
    post_reset_probe();
  endtask

  task body();
    // One reset per FSM state
    for (fsm_e st = st.first(); ; st = st.next()) begin
      reset_in_state(st);
      if (st == st.last()) break;
    end

    // Extra: reset at every BUSY cycle so every COMPUTE/WB of all 4 passes is hit
    for (int k = 0; k < 28; k++) begin
      apply_reset(2);
      idle_cycles(2);
      load_both_and_start();
      idle_cycles(k);
      apply_reset(2);
      post_reset_probe();
    end
  endtask
endclass
=======

>>>>>>> origin/main



class reset_abort_seq extends systolic_base_seq;
  `uvm_object_utils(reset_abort_seq)

  function new(string name = "reset_abort_seq");
    super.new(name);
  endfunction

  task body();
    apply_reset(2);
    load_a(8);
    apply_reset(2);
    start_and_wait_done();
    read_results(32);
  endtask
endclass


class ena_check_seq extends systolic_base_seq;

  `uvm_object_utils(ena_check_seq)

  function new(string name = "ena_check_seq");
    super.new(name);
  endfunction

  task body();

    apply_reset(2);

    load_a(16);
    load_b(16);

    req = seq_item::type_id::create("req");

    start_item(req);
    assert(req.randomize() with {
      rst_n  == 1'b1;
      ena    == 1'b1;
      uio_in == 8'h04;
      ui_in  == 8'h00;
    })
    else `uvm_error(get_type_name(), "START randomization failed")
    finish_item(req);

    repeat(5) begin

      start_item(req);
      assert(req.randomize() with {
        rst_n  == 1'b1;
        ena    == 1'b0;
        uio_in == 8'h00;
        ui_in  == 8'h00;
      })
      else `uvm_error(get_type_name(), "ENA LOW randomization failed")
      finish_item(req);

      start_item(req);
      assert(req.randomize() with {
        rst_n  == 1'b1;
        ena    == 1'b1;
        uio_in == 8'h00;
        ui_in  == 8'h00;
      })
      else `uvm_error(get_type_name(), "ENA HIGH randomization failed")
      finish_item(req);

    end

    idle_cycles(32);

    read_results(32);
  endtask

endclass

class matrix_load_seq extends systolic_base_seq;
  `uvm_object_utils(matrix_load_seq)

  function new(string name = "matrix_load_seq");
    super.new(name);
  endfunction

  task body();
    apply_reset(2);
    load_a(16);
	  idle_cycles(1);
    load_b(16);
	  idle_cycles(1);
    start_and_wait_done();
    read_results(32);
  endtask
endclass


class done_load_seq extends systolic_base_seq;

  `uvm_object_utils(done_load_seq)

  function new(string name = "done_load_seq");
    super.new(name);
  endfunction

  task body();

    apply_reset(2);

    load_a(16);
    load_b(16);
    start_and_wait_done();

    load_a(16);
    load_b(16);
    start_and_wait_done();

    idle_cycles(1);
    load_a(16);
    load_b(16);
    start_and_wait_done();

    idle_cycles(2);
    load_a(16);
    load_b(16);
    start_and_wait_done();
    read_results(32);

  endtask
endclass

class matrix_reload_seq extends systolic_base_seq;
  `uvm_object_utils(matrix_reload_seq)

  function new(string name = "matrix_reload_seq");
    super.new(name);
  endfunction

  task body();
    apply_reset(2);
    load_a(16);
    load_b(16);
    start_and_wait_done();
    read_results(32);

    load_a(16);
    start_and_wait_done();
    read_results(32);

    load_b(16);
    start_and_wait_done();
    read_results(32);
  endtask
endclass

class matrix_order_seq extends systolic_base_seq;
  `uvm_object_utils(matrix_order_seq)

  function new(string name = "matrix_order_seq");
    super.new(name);
  endfunction

  task body();
    logic [3:0] val_b;
    req = seq_item::type_id::create("req");
    apply_reset(2);
    for (int i = 0; i < 16; i++) begin
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b1; uio_in == 8'h01; ui_in == {4'h0, i[3:0]};}) else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
    idle_cycles(1);
    for (int i = 0; i < 16; i++) begin
      val_b = 15 - i;
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b1;uio_in == 8'h02; ui_in == {4'h0, val_b};}) else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
    idle_cycles(1);
    start_and_wait_done();
    read_results(32);
	
  endtask
endclass

class arithmetic_seq extends systolic_base_seq;
  `uvm_object_utils(arithmetic_seq)

  function new(string name = "arithmetic_seq");
    super.new(name);
  endfunction

  task body();
    req = seq_item::type_id::create("req");
    apply_reset(2);
    repeat(16) begin
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b1; ena == 1'b1; uio_in == 8'h01; ui_in == 8'h01;}) else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
    idle_cycles(1);
    repeat(16) begin
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b1; ena == 1'b1; uio_in == 8'h02; ui_in == 8'h01;}) else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
    idle_cycles(1);
    start_and_wait_done();
    read_results(32);
  endtask
endclass

class overflow_seq extends systolic_base_seq;
  `uvm_object_utils(overflow_seq)

  function new(string name = "overflow_seq");
    super.new(name);
  endfunction

  task body();
    req = seq_item::type_id::create("req");
    apply_reset(2);
    repeat(16) begin
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b1; ena == 1'b1; uio_in == 8'h01; ui_in == 8'h0F;}) else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
    idle_cycles(1);
    repeat(16) begin
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b1; ena == 1'b1; uio_in == 8'h02; ui_in == 8'h0F;}) else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
    idle_cycles(1);
    start_and_wait_done();
    read_results(32);
  endtask
endclass

class read_wrap_seq extends systolic_base_seq;
  `uvm_object_utils(read_wrap_seq)

  function new(string name = "read_wrap_seq");
    super.new(name);
  endfunction

  task body();
    apply_reset(2);
    load_a(16);
    load_b(16);
    start_and_wait_done();
    read_results(16);
    idle_cycles(4);
    read_results(48);
  endtask
endclass

class data_retain_seq extends systolic_base_seq;
  `uvm_object_utils(data_retain_seq)

  function new(string name = "data_retain_seq");
    super.new(name);
  endfunction

  task body();
    apply_reset(2);
    load_a(16);
    load_b(16);
    start_and_wait_done();
    idle_cycles(20);
    read_results(32);
  endtask
endclass

class random_test_seq extends systolic_base_seq;
  `uvm_object_utils(random_test_seq)

  function new(string name = "random_test_seq");
    super.new(name);
  endfunction

  task body();
    apply_reset(2);
    repeat(5) begin
      load_a(16);
      load_b(16);
      start_and_wait_done();
      read_results(32);
    end
  endtask
endclass

class priority_seq extends systolic_base_seq;
  `uvm_object_utils(priority_seq)

  function new(string name = "priority_seq");
    super.new(name);
  endfunction

  task body();
    req = seq_item::type_id::create("req");
    apply_reset(2);
    // Simultaneous LOAD_A and LOAD_B -> LOAD_A wins
    repeat(16) begin
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b1; ena == 1'b1; uio_in == 8'h03; ui_in[7:4] == 4'h0;}) else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
    idle_cycles(1);
    // Simultaneous LOAD_B and START -> LOAD_B wins
    repeat(16) begin
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b1; ena == 1'b1; uio_in == 8'h06; ui_in[7:4] == 4'h0;}) else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
    idle_cycles(1);
    start_and_wait_done();
    read_results(32);
  endtask
endclass

class wb_start_seq extends systolic_base_seq;
  `uvm_object_utils(wb_start_seq)

  function new(string name = "wb_start_seq");
    super.new(name);
  endfunction

  task body();
    req = seq_item::type_id::create("req");
    apply_reset(2);
    load_a(16);
    load_b(16);
    // Assert start
    start_item(req);
    assert(req.randomize() with {rst_n == 1'b1; ena == 1'b1; uio_in == 8'h04; ui_in == 8'h00;}) else `uvm_error(get_type_name(), "rand failed");
    finish_item(req);
    idle_cycles(28);
    // Assert start on final writeback cycle (ignored while BUSY)
    start_item(req);
    assert(req.randomize() with {rst_n == 1'b1; ena == 1'b1; uio_in == 8'h04; ui_in == 8'h00;}) else `uvm_error(get_type_name(), "rand failed");
    finish_item(req);
    idle_cycles(3);
    read_results(32);
  endtask
endclass

class invalid_req_seq extends systolic_base_seq;
  `uvm_object_utils(invalid_req_seq)

  function new(string name = "invalid_req_seq");
    super.new(name);
  endfunction

  task body();
    req = seq_item::type_id::create("req");
    apply_reset(2);
    // Try READ in IDLE (should be ignored)
    read_results(4);
    load_a(16);
    load_b(16);
    start_and_wait_done();
    read_results(32);
  endtask
endclass

class load_length_seq extends systolic_base_seq;
  `uvm_object_utils(load_length_seq)

  function new(string name = "load_length_seq");
    super.new(name);
  endfunction

  task body();
    apply_reset(2);
    load_a(20);
    load_b(16);
    start_and_wait_done();
    read_results(32);
  endtask
endclass

class back2back_seq extends systolic_base_seq;
  `uvm_object_utils(back2back_seq)

  function new(string name = "back2back_seq");
    super.new(name);
  endfunction

  task body();
    apply_reset(2);
    repeat(2) begin
      load_a(16);
      load_b(16);
      start_and_wait_done();
      read_results(32);
    end
  endtask
endclass

class upper_bits_seq extends systolic_base_seq;
  `uvm_object_utils(upper_bits_seq)

  function new(string name = "upper_bits_seq");
    super.new(name);
  endfunction

  task body();
    req = seq_item::type_id::create("req");
    apply_reset(2);
    repeat(16) begin
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b1; ena == 1'b1; uio_in == 8'hF1; ui_in[7:4] == 4'hF;}) else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
    idle_cycles(1);
    repeat(16) begin
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b1; ena == 1'b1; uio_in == 8'hF2; ui_in[7:4] == 4'hF;}) else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
    idle_cycles(1);
    start_and_wait_done();
    read_results(32);
  endtask
endclass

class read_retain_seq extends systolic_base_seq;
  `uvm_object_utils(read_retain_seq)

  function new(string name = "read_retain_seq");
    super.new(name);
  endfunction

  task body();
    apply_reset(2);
    load_a(16);
    load_b(16);
    start_and_wait_done();
    read_results(32);
    idle_cycles(10);
    read_results(32);
  endtask
endclass
