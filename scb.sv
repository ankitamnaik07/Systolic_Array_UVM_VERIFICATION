class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  uvm_tlm_analysis_fifo #(seq_item)mon_fifo;
  
   seq_item t;
  
  bit a_start =0;
  bit b_start =0;
  bit res_start = 0;
  bit [3:0]a_i, b_i;
  bit [5:0]res_i; 
  
  bit [3:0]arr_a[bit [3:0]];
  bit [3:0]arr_b[bit [3:0]];
  bit [7:0]result_arr[bit [5:0]]; 
  bit [10:0]exp_arr[bit [3:0]]; 
  
  bit [8:0]pass_cnt = 0, fail_cnt = 0, total_cnt = 0;
  
  function new(string name = "scoreboard",uvm_component parent = null);
    super.new(name, parent);
    
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   mon_fifo = new("mon_fifo", this);
  endfunction
 
  task run_phase(uvm_phase phase);
  
	forever begin
 	mon_fifo.get(t);

        if(!t.rst_n)begin
          a_start = 0;
          b_start = 0;
          arr_a.delete();
          arr_b.delete();
          total_cnt++;
          if(t.uo_out[3:0] != 4'd0 && t.uio_out[5:4] != 2'b0)begin
            fail_cnt++;
            `uvm_error("SCB", $sformatf("inputs A: %0p B: %0p actual : %0p expected 0: %p",arr_a, arr_b, result_arr, exp_arr));
          end
        end
        
        else begin 
          
          if(t.uio_in[0]) begin // load_a asserted 
            if(!a_start) begin 
              {a_start, b_start} = 2'b10;
              a_i = 4'd0;
            end
          
                arr_a[a_i] = t.ui_in;
		a_i++;
           end
          
          else if(t.uio_in[1]) begin // load_b
            if(!b_start)begin 
             {a_start, b_start } = 2'b01;
              b_i = 4'd0;
            end
          
            arr_b[b_i] = t.ui_in;
	    b_i = 4'd0;
	end
          
          else if(t.uio_in[2]) begin // read
            for(int i = result_arr.size(); i <result_arr.size()+1; i ++)begin 
              result_arr[i] = t.uo_out;
            end
          
          if(result_arr.size() == 32) compare(arr_a, arr_b, result_arr);
        end
          
          else if(t.uio_in[3])// start 
            result_arr.delete();
        end
	end
        
  endtask

 
  function compare(bit [3:0] arr_a[bit [3:0]],bit [3:0] arr_b[bit [3:0]],bit [7:0] result_arr[bit [5:0]]);
    
    //calculate expected output
    for(int i =0; i < 16;i = i+4)begin 
      for(int j =0; j < 4; j ++)begin 
        exp_arr[i+j]  = arr_a[i]*arr_b[j] + arr_a[i+1]*arr_b[j+4] + arr_a[i+2]*arr_b[j+8] + arr_a[i+3]*arr_b[j+12];
    end
    end
      
      foreach(exp_arr[i])begin 
        if(exp_arr[i] != {result_arr[2*i +1][1:0], result_arr[2*i]})begin
          fail_cnt ++;
          `uvm_error("SCB", $sformatf("inputs A: %0p B: %0p actual : %0p expected 0: %p",arr_a, arr_b, result_arr, exp_arr));
        end
      end
      total_cnt++;
  endfunction
      
      function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        pass_cnt = total_cnt - fail_cnt;
        
        `uvm_info("SCB", $sformatf("TOTAL=%0d PASS=%0d FAIL=%0d",
                total_cnt, pass_cnt, fail_cnt),
      UVM_LOW)
        
      endfunction
endclass
