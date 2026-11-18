interface intf(input clk);
  logic rst_n;
  logic ena;
  logic [7:0]ui_in;
  logic [7:0]uio_in;
  logic [7:0]uo_out;
  logic [7:0]uio_out;
  logic [7:0]uio_oe;
  
  clocking drv_cb @(posedge clk);
    default input #1step output #1step;
    input uo_out, uio_out, uio_oe, ena;
    output ui_in, uio_in, rst_n;
  endclocking
  
  clocking mon_cb @(posedge clk);
    default input #1 step;
    input ena, rst_n, ui_in, uio_in, uo_out, uio_out, uio_oe;
  endclocking 
  
  modport drv_mon(clocking drv_cb, clk);
  modport mon_mon(clocking mon_cb, clk);    
  
endinterface 
