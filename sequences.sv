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
      assert(req.randomize() with {rst_n == 1'b1;  uio_in == 8'h08; ui_in == 8'h00;}) else `uvm_error(get_type_name(), "rand failed");
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
    start_and_wait_done();
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
    //read_results(32);
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
      assert(req.randomize() with {rst_n == 1'b1; ena == 1'b1; uio_in == 8'h01; ui_in == {4'h0, i[3:0]};}) else `uvm_error(get_type_name(), "rand failed");
      finish_item(req);
    end
    idle_cycles(1);
    for (int i = 0; i < 16; i++) begin
      val_b = 15 - i;
      start_item(req);
      assert(req.randomize() with {rst_n == 1'b1; ena == 1'b1; uio_in == 8'h02; ui_in == {4'h0, val_b};}) else `uvm_error(get_type_name(), "rand failed");
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
