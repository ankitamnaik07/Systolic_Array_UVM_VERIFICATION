class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  uvm_tlm_analysis_fifo #(seq_item)mon_fifo;
  seq_item t;
  
  static bit a_start =0;
  static bit b_start =0;
  static bit res_start = 0;
  
  bit [3:0]arr_a[bit [3:0]];
  bit [3:0]arr_b[bit [3:0]];
  bit [7:0]result_arr[bit [5:0]]; 
  bit [10:0]exp_arr[bit [3:0]]; 
  
  bit [8:0]pass_cnt, fail_cnt, total_cnt;
  
  function new(string name = "scoreboard",uvm_component parent = "null");
    super.new(name, parent);
    
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_fifo = new("mon_imp", this);
  endfunction
  
    task run_phase(uvm_phase phase);
    pass_cnt =0;
    fail_cnt = 0;
    total_cases = 0;
      
      forever begin 
        mon_exp.get(t);
        
        if(!t.rst_n)begin
          arr_a.delete();
          arr_b.delete();
          total_cnt++;
          if(t.uo_out[3:0] != 4'd0 && uio_out[5:4] != 2'b0)begin
            fail_cnt++;
            `uvm_error("SCB", $sformatf("inputs A: %0s B: %0s actual : %0s expected 0: %s",arr_a, arr_b, result_arr, exp_arr));
          end
        end
        
        else begin 
          
          if(t.uio_in[0]) // load_a asserted 
            for(int i = arr_a.size(); i <arr_a.size()+1; i ++) 
              arr_a[i] = t.ui_in;
          
          else if(t.uio_in[1]) // load_b  
            for(int i = arr_b.size(); i<arr_b.size()+1; i ++) 
              arr_b[i] = t.ui_in;
          
          else if(t.uio_in[2]) // result 
            for(int i = result_arr.size(); i <result_arr.size()+1; i ++)begin 
              result_arr[i] = t.uo_out;
            end
          
          if(result_arr.size() == 32) compare(arr_a, arr_b, result_arr);
        end
        
      end
    endtask
  
  function compare(bit [3:0] arr_a[bit [3:0]],bit [3:0] arr_b[bit [3:0]],bit [3:0] result_arr[bit [5:0]]);
    
    //calculate expected output
    for(int i =0; i < 16; i+4)begin 
      for(int j =0; j < 4; j ++)begin 
        exp_result[i+j]  = a[i]*b[j] + a[i+1]*b[j+4] + a[i+2]*b[j+8] + a[i+3]*b[j+12];
    end
      
      foreach(exp_arr[i])begin 
        if(exp_arr[i] != {result_arr[2*i +1][1:0], result_arr[2*i]})begin
          fail_cnt ++;
          `uvm_error("SCB", $sformatf("inputs A: %0s B: %0s actual : %0s expected 0: %s",arr_a, arr_b, result_arr, exp_arr));
        end
      end
      total_cnt++;
  endfunction
  

  
  
endclass
