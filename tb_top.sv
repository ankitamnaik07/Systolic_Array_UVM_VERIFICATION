`timescale 1ns/1ps

`include "uvm_macros.svh"
`include "systolic_tb_pkg.sv"

module tb_top;

  import uvm_pkg::*;
  import systolic_tb_pkg::*;

  bit clk;

  always #5 clk = ~clk;

  intf vif(clk);

  // DUT instantiation
  tt_um_systolic_mm dut (
    .clk     (clk),
    .rst_n   (vif.rst_n),
    .ena     (vif.ena),
    .ui_in   (vif.ui_in),
    .uo_out  (vif.uo_out),
    .uio_in  (vif.uio_in),
    .uio_out (vif.uio_out),
    .uio_oe  (vif.uio_oe)
  );

  initial begin

    uvm_config_db #(virtual intf)::set(
      null, "*", "vif", vif
    );

    run_test();

  end

endmodule
