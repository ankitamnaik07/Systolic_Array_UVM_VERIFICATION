interface intf(input logic clk);

import uvm_pkg::*;

  logic rst_n;
  logic ena;
  logic [7:0] ui_in;
  logic [7:0] uio_in;
  logic [7:0] uo_out;
  logic [7:0] uio_out;
  logic [7:0] uio_oe;

  clocking drv_cb @(posedge clk);
    default input #1step output #1step;

    input uo_out, uio_out, uio_oe;
    output ena, ui_in, uio_in;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step;

    input ena, ui_in, uio_in;
    input uo_out, uio_out, uio_oe;
  endclocking

  modport drv_mon(clocking drv_cb, output rst_n);
  modport mon_mon(clocking mon_cb, input rst_n);

 property rst_check;
    @(posedge clk)
    !(rst_n) |-> uo_out == 8'd0 && uio_out == 8'd0;
  endproperty
  
  assert property(rst_check)
    else `uvm_error("RST ASRTN FAILED", $sformatf("uo_out=%0d uio_out=%0d",uo_out, uio_out));
                                             
    property valid_signals;
      @(posedge clk)
      disable iff(!rst_n)
      !$isunknown({ui_in, uio_in[3:0], rst_n});
    endproperty
    
    assert property (valid_signals)
      else `uvm_error("VALID SIGNAL ASRTN FAILED", $sformatf("ui_in=%0d uio_in=%0d, rst_n = %0d",ui_in, uio_in, rst_n));
<<<<<<< HEAD

   sequence start_proper;
	uio_in[2] && !uio_in[1] && !uio_in[0] && !uio_out[4] && $past({uio_in[3], uio_in[1:0]} == 3'b0);
    endsequence 
 
      property busy_value;
        @(posedge clk)
        disable iff(!rst_n)
        //(uio_in[2:0] == 3'b100 && !uio_out[4]) |=> (uio_out[4] && !uio_out[5])[*29];
        start_proper |=> (uio_out[4])[*28] ##1 (!uio_out[4] && uio_out[5]);
=======
      
      property busy_value;
        disable iff(!rst_n)
        @(posedge clk)
        (uio_in[2:0] == 3'b100 and !uio_out[4]) |=> (uio_out[4] && !uio_out[5])[*29];
>>>>>>> origin/main
      endproperty
      
        
        property done_value;
<<<<<<< HEAD
          @(posedge clk)
          disable iff(!rst_n)
          //uio_in[2] && !uio_out[4] |-> ##29 uio_out[5];
          start_proper |-> ##29 uio_out[5];
=======
          disable iff(!rst_n)
          @(posedge clk)
          uio_in[2] and !uio_out[4] |-> ##29 uio_out[5];
>>>>>>> origin/main
        endproperty
        
      assert property (done_value)
        else `uvm_error("COMPUTATION CYCLE ASRTN FAILED", $sformatf("BUSY=%0d, DONE = %0d", uio_out[4], uio_out[5]));
<<<<<<< HEAD
  
     assert property (busy_value)
        else `uvm_error("COMPUTATION CYCLE ASRTN FAILED", $sformatf("BUSY=%0d, DONE = %0d", uio_out[4], uio_out[5]));
   
=======
      
     assert property (busy_value)
        else `uvm_error("COMPUTATION CYCLE ASRTN FAILED", $sformatf("BUSY=%0d, DONE = %0d", uio_out[4], uio_out[5]));
        
>>>>>>> origin/main
        property done_busy;
          disable iff(!rst_n)
          @(posedge clk) 
          uio_out[4] |-> !uio_out[5];
        endproperty
        
        property busy_done;
          disable iff(!rst_n)
          @(posedge clk) 
          uio_out[5] |-> !uio_out[4];
        endproperty
        
        assert property(busy_done)
          else `uvm_error("BUSY DONE ASRTN FAILED", $sformatf("BUSY = %0d DONE = %0d", uio_out[4], uio_out[5]));
          
        assert property(done_busy)
          else `uvm_error("BUSY DONE ASRTN FAILED", $sformatf("BUSY = %0d DONE = %0d", uio_out[4], uio_out[5]));
          
          property forced_values;
            @(posedge clk)
            uio_oe == 8'b11110000 and {uio_out[7:6],uio_out[3:0]} == 6'd0 ;
          endproperty
          
          assert property (forced_values)
            else `uvm_error("FORCED VALUE ASRTN FAILED", $sformatf("uio_oe = %0d,uio_out[7:6] = %0d, uio_out[3:0] = %0d ", uio_oe,uio_out[7:6],uio_out[3:0]));
<<<<<<< HEAD
           
=======
            
>>>>>>> origin/main
           endinterface  
