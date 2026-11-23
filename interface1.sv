
interface intf(input logic clk);

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
    output rst_n, ena, ui_in, uio_in;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step;
    input ena, ui_in, uio_in, rst_n;
    input uo_out, uio_out, uio_oe;
  endclocking

  modport drv_mon(clocking drv_cb);
  modport mon_mon(clocking mon_cb);

endinterface

