class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_tlm_analysis_fifo #(seq_item) mon_fifo;
  seq_item t;

  bit [3:0] arr_a[0:15];
  bit [3:0] arr_b[0:15];

  bit [10:0] exp_arr[0:15];

//  bit in_read;
  bit prev_start;
  bit prev_load_a;
  bit prev_load_b;

  int load_a_idx;
  int load_b_idx;
  int read_idx;

  int pass_cnt, fail_cnt, total_cnt;
  int reset_fail_cnt;

  function new(string name = "scoreboard",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_fifo = new("mon_fifo", this);
  endfunction

  function void clear_model();
    for(int i = 0; i < 16; i++) begin
      arr_a[i] = 0;
      arr_b[i] = 0;
      exp_arr[i] = 0;
    end

    load_a_idx = 0;
    load_b_idx = 0;
    read_idx = 0;

  //  in_read = 0;
    prev_start = 0;
    prev_load_a = 0;
    prev_load_b = 0;
  endfunction

/*  function void print_input_matrices();
    `uvm_info("MATRIX", "========== INPUT MATRIX A ==========", UVM_LOW)
    for(int i = 0; i < 4; i++) begin
      `uvm_info("MATRIX",
        $sformatf("%0d  %0d  %0d  %0d",
          arr_a[i*4],
          arr_a[i*4+1],
          arr_a[i*4+2],
          arr_a[i*4+3]),
        UVM_LOW)
    end

    `uvm_info("MATRIX", "========== INPUT MATRIX B ==========", UVM_LOW)
    for(int i = 0; i < 4; i++) begin
      `uvm_info("MATRIX",
        $sformatf("%0d  %0d  %0d  %0d",
          arr_b[i*4],
          arr_b[i*4+1],
          arr_b[i*4+2],
          arr_b[i*4+3]),
        UVM_LOW)
    end
  endfunction
*/
  function void calculate_expected();
    int unsigned sum;

    for(int i = 0; i < 16; i += 4) begin
      for(int j = 0; j < 4; j++) begin
        sum = int'(arr_a[i])   * int'(arr_b[j])     +
              int'(arr_a[i+1]) * int'(arr_b[j+4])   +
              int'(arr_a[i+2]) * int'(arr_b[j+8])   +
              int'(arr_a[i+3]) * int'(arr_b[j+12]);

        exp_arr[i+j] = sum[10:0];
      end
    end

    `uvm_info("MATRIX", "========== EXPECTED MATRIX C ==========", UVM_LOW)
    for(int i = 0; i < 4; i++) begin
      `uvm_info("MATRIX",
        $sformatf("%0d  %0d  %0d  %0d",
          exp_arr[i*4],
          exp_arr[i*4+1],
          exp_arr[i*4+2],
          exp_arr[i*4+3]),
        UVM_LOW)
    end
  endfunction

  function void compare_byte();
    bit [7:0] expected_byte;

    if(read_idx % 2 == 0)
      expected_byte = exp_arr[read_idx/2][7:0];
    else
      expected_byte = {6'b0, exp_arr[read_idx/2][9:8]};

    total_cnt++;

    if(t.uo_out !== expected_byte) begin
      fail_cnt++;
      `uvm_error("SCB",
        $sformatf("BYTE[%0d]: actual=0x%0h (%0d) expected=0x%0h (%0d)",
                  read_idx, t.uo_out, t.uo_out, expected_byte, expected_byte))
    end
    else begin
      pass_cnt++;
      //`uvm_info("SCB",
        //$sformatf("BYTE[%0d]: actual=0x%0h (%0d) expected=0x%0h (%0d) PASS",
          //        read_idx, t.uo_out, t.uo_out, expected_byte, expected_byte),
        //UVM_LOW)
    end

    if(read_idx == 31)
      read_idx = 0;
    else
      read_idx++;
  endfunction

  task run_phase(uvm_phase phase);
    pass_cnt = 0;
    fail_cnt = 0;
    total_cnt = 0;
    reset_fail_cnt = 0;

    clear_model();

    forever begin
      mon_fifo.get(t);

      if(t.rst_n === 1'b0) begin
        if(t.uo_out !== 8'd0 || t.uio_out[5:4] !== 2'b00) begin
          reset_fail_cnt++;
          `uvm_error("SCB",
            $sformatf("Reset check failed: uo_out=%0h BUSY/DONE=%b expected all 0",
                      t.uo_out, t.uio_out[5:4]))
        end
        clear_model();
      end
      else if(t.rst_n === 1'b1) begin
        if(t.uio_in[2] && !prev_start && !t.uio_out[4] && !t.uio_in[0] && !t.uio_in[1]) begin
//          print_input_matrices();
          calculate_expected();
          read_idx = 0;
    //      in_read = 0;
        end

    //    if(t.uio_out[4]) begin
    //    end
        else if(t.uio_in[0]) begin
          if(!prev_load_a)
            load_a_idx = 0;
          arr_a[load_a_idx % 16] = t.ui_in[3:0];
          load_a_idx++;
          //in_read = 0;
        end
        else if(t.uio_in[1]) begin
          if(!prev_load_b)
            load_b_idx = 0;
          arr_b[load_b_idx % 16] = t.ui_in[3:0];
          load_b_idx++;
          //in_read = 0;
        end
      /*  else if(t.uio_in[2]) begin
          in_read = 0;
        end
       */ else if(t.uio_in[3]) begin
          if(t.uio_out[5]) begin
           // in_read = 1;
            compare_byte();
          end
        end
       /* else begin
          in_read = 0;
        end*/
      end
      else begin
        `uvm_error("SCB", "rst_n is X or Z")
      end

      prev_start  = (t.rst_n === 1'b1 && !t.uio_out[4] && !t.uio_in[0] && !t.uio_in[1]) ? t.uio_in[2] : 1'b0;
      prev_load_a = (t.rst_n === 1'b1 && !t.uio_out[4]) ? t.uio_in[0] : 1'b0;
      prev_load_b = (t.rst_n === 1'b1 && !t.uio_out[4] && !t.uio_in[0]) ? t.uio_in[1] : 1'b0;
    end
  endtask

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCB",
      $sformatf("TOTAL=%0d PASS=%0d FAIL=%0d RESET_FAIL=%0d",
                total_cnt, pass_cnt, fail_cnt, reset_fail_cnt),
      UVM_LOW)
  endfunction

endclass
