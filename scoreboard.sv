class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  uvm_tlm_analysis_fifo #(seq_item)mon_fifo;
  seq_item t;
  
  bit [3:0]arr_a[bit [3:0]];
  bit [3:0]arr_b[bit [3:0]];
  bit [7:0]result_arr[bit [5:0]];
  bit [10:0]exp_arr[bit [3:0]]; 
  
  bit in_read;
  
  int pass_cnt, fail_cnt, total_cnt;
  
  function new(string name = "scoreboard",uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_fifo = new("mon_fifo", this);
  endfunction
  
  function void clear_model();
    arr_a.delete(); arr_b.delete(); result_arr.delete(); exp_arr.delete();
    for(int i = 0; i < 16; i++) begin
      arr_a[i] = 0;
      arr_b[i] = 0;
    end
    in_read = 0;
  endfunction
  
  task run_phase(uvm_phase phase);
    pass_cnt = 0;
    fail_cnt = 0;
    total_cnt = 0;
    clear_model();
      
    forever begin 
      mon_fifo.get(t);
        
      if(!t.rst_n)begin
        total_cnt++;
        if(t.uo_out != 8'd0 || t.uio_out[5:4] != 2'b0)begin
          fail_cnt++;
          `uvm_error("SCB", $sformatf("after reset: uo_out=%0h BUSY/DONE=%b expected all 0", t.uo_out, t.uio_out[5:4]));
        end
        else pass_cnt++;
        clear_model();
      end
        
      else begin 
        
        if(t.uio_out[4]) begin
        end
        
        else if(in_read) begin
          if(t.uio_in[3]) begin
            result_arr[result_arr.size()] = t.uo_out;
            if(result_arr.size() == 32) begin
              compare(arr_a, arr_b, result_arr);
              result_arr.delete();
            end
          end
          else in_read = 0;
        end
          
        else if(t.uio_in[0]) begin
          if(arr_a.size() == 16) arr_a.delete();
          arr_a[arr_a.size()] = t.ui_in[3:0];
        end
          
        else if(t.uio_in[1]) begin
          if(arr_b.size() == 16) arr_b.delete();
          arr_b[arr_b.size()] = t.ui_in[3:0];
        end
          
        else if(t.uio_in[2]) begin
        end
          
        else if(t.uio_in[3] && t.uio_out[5]) begin
          in_read = 1;
          result_arr[result_arr.size()] = t.uo_out;
        end
          
      end
        
    end
  endtask
  
  function void compare(bit [3:0] a[bit [3:0]], bit [3:0] b[bit [3:0]], bit [7:0] res[bit [5:0]]);
    int errs = 0;
    
    for(int i = 0; i < 16; i += 4)begin
      for(int j = 0; j < 4; j ++)begin 
        exp_arr[i+j] = a[i]*b[j] + a[i+1]*b[j+4] + a[i+2]*b[j+8] + a[i+3]*b[j+12];
      end
    end
      
    foreach(exp_arr[i])begin 
      if(exp_arr[i] != {res[2*i +1][1:0], res[2*i]})begin
        errs++;
        `uvm_error("SCB", $sformatf("C[%0d][%0d]: actual=0x%0h expected=0x%0h", i/4, i%4, {res[2*i+1][1:0], res[2*i]}, exp_arr[i]));
      end
    end
    
    total_cnt++;
    if(errs == 0) pass_cnt++;
    else begin
      fail_cnt++;
      `uvm_info("SCB", $sformatf("inputs A: %p B: %p actual: %p expected: %p", a, b, res, exp_arr), UVM_LOW)
    end
  endfunction
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCB", $sformatf("TOTAL=%0d PASS=%0d FAIL=%0d", total_cnt, pass_cnt, fail_cnt), UVM_LOW)
  endfunction
     
endclass
