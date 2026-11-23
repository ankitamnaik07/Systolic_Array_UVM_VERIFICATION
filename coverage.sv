
class systolic_coverage extends uvm_subscriber #(seq_item);

  `uvm_component_utils(systolic_coverage)

  bit [3:0] ui_in;
  bit [3:0] uio_in;
  bit       rst_n;

  covergroup systolic_cg;

    option.per_instance = 1;

    // Data coverage
    cp_ui_in: coverpoint ui_in[3:0] {
      bins ui_in_low[] = {[0:15]};
    }

    // Control signal coverage
    cp_load_a: coverpoint uio_in[0] {
      bins low  = {0};
      bins high = {1};
    }

    cp_load_b: coverpoint uio_in[1] {
      bins low  = {0};
      bins high = {1};
    }

    cp_start: coverpoint uio_in[2] {
      bins low  = {0};
      bins high = {1};
    }

    cp_read: coverpoint uio_in[3] {
      bins low  = {0};
      bins high = {1};
    }

    // Reset coverage
    rst_bin: coverpoint rst_n {
      bins reset_active   = {0};
      bins reset_inactive = {1};
    }

    // Cross coverage
    cross_load_a: cross cp_ui_in, cp_load_a;
    cross_load_b: cross cp_ui_in, cp_load_b;
    cross_start:  cross cp_ui_in, cp_start;
    cross_read:   cross cp_ui_in, cp_read;

  endgroup


  function new(string name = "systolic_coverage",
               uvm_component parent = null);

    super.new(name, parent);
    systolic_cg = new();

  endfunction


  virtual function void write(seq_item t);

    ui_in = t.ui_in[3:0];
    uio_in = t.uio_in[3:0];
    rst_n = t.rst_n;

    systolic_cg.sample();

  endfunction

endclass

