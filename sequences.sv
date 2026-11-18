class systolic_base_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(systolic_base_seq)
  seq_item req;

  bit [3:0] A[16];
  bit [3:0] B[16];

  function new(string name="systolic_base_seq");
    super.new(name);
  endfunction

  // Drive one transaction
  task drive(bit [7:0] data, bit [7:0] ctrl, bit reset_n=1);
	req = seq_item::type_id::create("req");
	start_item(req);
	assert(req.randomize(ui_in,uio_in,rst_n) with {
	ui_in  == data;
      	uio_in == ctrl;
      	rst_n  == reset_n;
    })
    	else `uvm_error(get_type_name(),"Randomization failed")
    	finish_item(req);	
  endtask

  // Reset
  task reset_dut();
    repeat(2)
      drive(0,0,0);
    drive(0,0,1);
  endtask

  // Load Matrix A
  task load_A();
    for(int i=0;i<16;i++)
      drive(A[i],8'h01);
    // Release load
    drive(0,0);
  endtask

  // Load Matrix B
  task load_B();
    for(int i=0;i<16;i++)
      drive(B[i],8'h02);
    // Release load
    drive(0,0);
  endtask

  // Wait for computation to finish
  // Specified computation latency: 29 cycles
  task wait_done();
    repeat(29)
      drive(0,0);
  endtask

  // Start computation
  task start_compute();
    drive(0,8'h04);
    wait_done();
  endtask

  // Read result
  task read_result(int count=32);
    repeat(count)
      drive(0,8'h08);
    // Release READ
    drive(0,0);
  endtask

endclass



class reset_idle_seq extends systolic_base_seq;
  `uvm_object_utils(reset_idle_seq)

  function new(string name="reset_idle_seq");
    super.new(name);
  endfunction

  task body();
    reset_dut();

    repeat(5)
      drive(0,0);

    reset_dut();
  endtask
endclass


class reset_abort_seq extends systolic_base_seq;
  `uvm_object_utils(reset_abort_seq)

  function new(string name="reset_abort_seq");
    super.new(name);
  endfunction

  task body();
    for(int i=0;i<16;i++) begin
      A[i]=i;
      B[i]=15-i;
    end

    // Reset during LOAD_A
    drive(1,1);
    drive(2,1);
    reset_dut();

    // Reset during LOAD_B
    load_A();

    drive(1,2);
    drive(2,2);

    reset_dut();

    // Reset during COMPUTE
    load_A();
    load_B();

    drive(0,4);

    repeat(5)
      drive(0,0);

    reset_dut();

    // Reset during WB
    load_A();
    load_B();

    drive(0,4);

    repeat(27)
      drive(0,0);

    reset_dut();

    // Reset during DONE
    load_A();
    load_B();

    start_compute();

    reset_dut();

    // Reset during READ
    load_A();
    load_B();

    start_compute();

    repeat(5)
      drive(0,8);

    reset_dut();

    // Compute after reset without reloading
    start_compute();

    read_result();

  endtask

endclass


class ena_check_seq extends systolic_base_seq;
  `uvm_object_utils(ena_check_seq)

  function new(string name="ena_check_seq");
    super.new(name);
  endfunction

  task body();
    for(int i=0;i<16;i++) begin
      A[i]=i;
      B[i]=15-i;
    end

    load_A();
    load_B();

    // START with ENA randomized
    req = seq_item::type_id::create("req");
    start_item(req);

    assert(req.randomize(ui_in,uio_in,ena) with {
      ui_in==0;
      uio_in==8'h04;
      ena==0;
    })
    else `uvm_error(get_type_name(),"Randomization failed")

    finish_item(req);

    // Toggle ENA during computation
    repeat(28) begin
      start_item(req);
      assert(req.randomize(ui_in,uio_in,ena) with {
        ui_in==0;
        uio_in==0;
        ena inside {0,1};
      })
      else `uvm_error(get_type_name(),"Randomization failed")
      finish_item(req);
    end

    read_result();
  endtask

endclass

class matrix_load_seq extends systolic_base_seq;
  `uvm_object_utils(matrix_load_seq)

  function new(string name="matrix_load_seq");
    super.new(name);
  endfunction

  task body();
    // Matrix A
    for(int i=0;i<16;i++)
      A[i]=i;

    // Matrix B: Identity
    for(int i=0;i<16;i++)
      B[i]=0;

    B[0]=1;
    B[5]=1;
    B[10]=1;
    B[15]=1;

    // Verify A using identity matrix
    load_A();
    load_B();
    start_compute();
    read_result();

    // Verify B using identity matrix
    for(int i=0;i<16;i++)
      A[i]=B[i];

    for(int i=0;i<16;i++)
      B[i]=15-i;

    load_A();
    load_B();
    start_compute();
    read_result();

    // Verify both matrices
    for(int i=0;i<16;i++) begin
      A[i]=i;
      B[i]=15-i;
    end

    load_A();
    load_B();
    start_compute();
    read_result();

  endtask
endclass



class done_load_seq extends systolic_base_seq;
  `uvm_object_utils(done_load_seq)

  function new(string name="done_load_seq");
    super.new(name);
  endfunction

  task body();
   for(int i=0;i<16;i++) begin
      A[i]=i;
      B[i]=15-i;
    end

    load_A();
    load_B();
    start_compute();

    // Load A directly from DONE
    load_A();

    // Load B after release gap
    repeat(2)
      drive(0,0);
    load_B();

    start_compute();
    read_result();
  endtask

endclass

class matrix_reload_seq extends systolic_base_seq;
  `uvm_object_utils(matrix_reload_seq)

  function new(string name="matrix_reload_seq");
    super.new(name);
  endfunction

  task body();
    for(int i=0;i<16;i++) begin
      A[i]=i;
      B[i]=15-i;
    end

    load_A();
    load_B();
    start_compute();
    read_result();

    // Reload only A
    for(int i=0;i<16;i++)
      A[i]=15-i;

    load_A();
    start_compute();
    read_result();

    // Reload only B
    for(int i=0;i<16;i++)
     B[i]=i;

    load_B();

    start_compute();
    read_result();
  endtask

endclass


class matrix_order_seq extends systolic_base_seq;
  `uvm_object_utils(matrix_order_seq)

  function new(string name="matrix_order_seq");
    super.new(name);
  endfunction

  task body();

   for(int i=0;i<16;i++) begin
      A[i]=(i*3+1)%16;
      B[i]=(i*5+2)%16;
    end

    load_A();
    load_B();
    start_compute();
    read_result();

    // Exchange A and B
    for(int i=0;i<16;i++) begin
      A[i]=(i*5+2)%16;
      B[i]=(i*3+1)%16;
    end

    load_A();
    load_B();
    start_compute();
    read_result();
  endtask

endclass

class arithmetic_seq extends systolic_base_seq;
  `uvm_object_utils(arithmetic_seq)

  function new(string name="arithmetic_seq");
    super.new(name);
  endfunction

  task body();
    // Both matrices zero
    for(int i=0;i<16;i++) begin
      A[i]=0;
      B[i]=0;
    end

    load_A();
    load_B();
    start_compute();
    read_result();

    // Identity x known matrix
    for(int i=0;i<16;i++) begin
      A[i]=0;
      B[i]=i;
    end

    A[0]=1;
    A[5]=1;
    A[10]=1;
    A[15]=1;

    load_A();
    load_B();
    start_compute();
    read_result();

    // Both matrices filled with ones
    for(int i=0;i<16;i++) begin
      A[i]=1;
      B[i]=1;
    end

    load_A();
    load_B();
    start_compute();
    read_result();
  endtask

endclass

class overflow_seq extends systolic_base_seq;
  `uvm_object_utils(overflow_seq)

  function new(string name="overflow_seq");
    super.new(name);
  endfunction

  task run_value(
    int target,
    bit [3:0] a0,a1,a2,a3,
    bit [3:0] b0,b1,b2,b3
  );

    for(int i=0;i<16;i++) begin
      A[i]=0;
      B[i]=0;
    end

    A[0]=a0;
    A[1]=a1;
    A[2]=a2;
    A[3]=a3;

    B[0]=b0;
    B[4]=b1;
    B[8]=b2;
    B[12]=b3;

    load_A();
    load_B();

    start_compute();
    read_result();

    `uvm_info("BOUNDARY",$sformatf("Testing expected C[0][0] = %0d",target),UVM_LOW)
  endtask

  task body();
    // 255
    run_value(255,0,0,2,15,0,0,15,15);

    // 256
    run_value(256,0,0,4,14,0,0,15,14);

    // 257
    run_value(257,0,0,4,15,0,0,8,15);

    // 511
    run_value(511,0,6,14,15,0,15,14,15);

    // 512
    run_value(512,0,7,14,15,0,11,15,15);

    // 768
    run_value(768,9,14,15,15,12,15,15,15);

    // Maximum 900
    run_value(900,15,15,15,15,15,15,15,15);

  endtask
endclass

class read_wrap_seq extends systolic_base_seq;
  `uvm_object_utils(read_wrap_seq)

  function new(string name="read_wrap_seq");
    super.new(name);
  endfunction

  task body();
    for(int i=0;i<16;i++) begin
      A[i]=i;
      B[i]=15-i;
    end

    load_A();
    load_B();

    start_compute();
    // Read 40 bytes to check pointer wrap
    read_result(40);

    // New computation
    start_compute();

    // Read 10 bytes
    repeat(10)
      drive(0,8);

    // Pause and resume
    drive(0,0);

    read_result(22);
  endtask

endclass

class data_retain_seq extends systolic_base_seq;
  `uvm_object_utils(data_retain_seq)

  function new(string name="data_retain_seq");
    super.new(name);
  endfunction

  task body();
    for(int i=0;i<16;i++) begin
      A[i]=i;
      B[i]=15-i;
    end

    load_A();
    load_B();
    start_compute();
    read_result();

    // Wait in DONE
    repeat(20)
      drive(0,0);

    // Compute again without loading
    start_compute();
    read_result();
  endtask

endclass


class random_test_seq extends systolic_base_seq;
  `uvm_object_utils(random_test_seq)

  function new(string name="random_test_seq");
    super.new(name);
  endfunction

  task body();
    repeat(500) begin
      for(int i=0;i<16;i++) begin
        A[i]=$urandom_range(0,15);
        B[i]=$urandom_range(0,15);
      end

      load_A();
      load_B();
      start_compute();

      // Random pause before reading
      repeat($urandom_range(1,3))
        drive(0,0);

      read_result();
    end
  endtask

endclass



class priority_seq extends systolic_base_seq;
 `uvm_object_utils(priority_seq)

  function new(string name="priority_seq");
    super.new(name);
  endfunction

  task body();
    for(int i=0;i<16;i++) begin
      A[i]=i;
      B[i]=15-i;
    end

    // Request combinations in IDLE
    for(int i=0;i<16;i++) begin

      reset_dut();

      drive(5,i);

      // Allow time for selected operation
      repeat(29)
        drive(0,0);
    end

    // Request combinations in DONE
    for(int i=0;i<16;i++) begin
      reset_dut();
      load_A();
      load_B();
      start_compute();

      drive(5,i);

      repeat(29)
        drive(0,0);

    end
  endtask

endclass



class wb_start_seq extends systolic_base_seq;
 `uvm_object_utils(wb_start_seq)

  function new(string name="wb_start_seq");
    super.new(name);
  endfunction

  task body();
    for(int i=0;i<16;i++) begin
      A[i]=i;
      B[i]=15-i;
    end

    load_A();
    load_B();

    // Start computation
    drive(0,4);

    // Reach final writeback
    repeat(27)
      drive(0,0);

    // START during final WB
    drive(0,4);

    // Allow original computation to finish
    wait_done();
    read_result();

  endtask
endclass


class invalid_req_seq extends systolic_base_seq;
  `uvm_object_utils(invalid_req_seq)

  function new(string name="invalid_req_seq");
    super.new(name);
  endfunction

  task body();
    for(int i=0;i<16;i++) begin
      A[i]=i;
      B[i]=15-i;
    end

    // READ during IDLE
    drive(0,8);
    drive(0,0);

    load_A();
    load_B();

    // Start computation
    drive(0,4);

    // Invalid requests during COMPUTE
    repeat(5) begin
      drive(5,1);
      drive(6,2);
      drive(0,4);
      drive(0,8);
    end

    // Wait for computation to finish
    wait_done();
    read_result();

    start_compute();

    // Enter READ
    drive(0,8);

    // Invalid LOAD and START during READ
    drive(5,1);
    drive(6,2);
    drive(0,4);

    // Continue reading
    repeat(29)
      drive(0,8);

    drive(0,0);
  endtask

endclass



class load_length_seq extends systolic_base_seq;
  `uvm_object_utils(load_length_seq)

  function new(string name="load_length_seq");
    super.new(name);
  endfunction

  task body();
    for(int i=0;i<16;i++) begin
      A[i]=i;
      B[i]=15-i;
    end

    // Load complete matrices first
    load_A();
    load_B();
    start_compute();
    read_result();

    // Partial LOAD_A: 8 cycles
    repeat(8)
      drive(5,1);

    drive(0,0);

    start_compute();
    read_result();

    // Overlength LOAD_A: 20 cycles
    repeat(20)
      drive(10,1);

    drive(0,0);

    start_compute();
    read_result();
  endtask

endclass


class back2back_seq extends systolic_base_seq;
  `uvm_object_utils(back2back_seq)

  function new(string name="back2back_seq");
    super.new(name);
  endfunction

  task body();

    for(int i=0;i<16;i++) begin
      A[i]=i;
      B[i]=15-i;
    end

    load_A();
    load_B();
    start_compute();
    read_result();

    start_compute();
    read_result();

    start_compute();
    read_result();

  endtask
endclass


class upper_bits_seq extends systolic_base_seq;

  `uvm_object_utils(upper_bits_seq)

  function new(string name="upper_bits_seq");
    super.new(name);
  endfunction

  task body();

    for(int i=0;i<16;i++) begin
      A[i]=i;
      B[i]=15-i;
    end

    // Load A with upper nibble 0
    for(int i=0;i<16;i++)
      drive({4'h0,A[i]},1);

    drive(0,0);

    load_B();

    start_compute();
    read_result();

    // Load A with upper nibble F
    for(int i=0;i<16;i++)
      drive({4'hF,A[i]},1);

    drive(0,0);

    start_compute();
    read_result();

    // Change upper nibble of B also
    for(int i=0;i<16;i++)
      drive({4'hA,B[i]},2);

    drive(0,0);

    start_compute();
    read_result();

  endtask

endclass


class read_retain_seq extends systolic_base_seq;

  `uvm_object_utils(read_retain_seq)

  function new(string name="read_retain_seq");
    super.new(name);
  endfunction

  task body();

    for(int i=0;i<16;i++) begin
      A[i]=i;
      B[i]=15-i;
    end

    load_A();
    load_B();

    start_compute();

    // Read first 10 bytes
    repeat(10)
      drive(0,8);

    // Pause READ
    drive(0,0);

    // Resume from previous pointer
    read_result(22);

  endtask

endclass
