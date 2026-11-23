class seq_item extends uvm_sequence_item;
  `uvm_object_utils(seq_item)

  rand bit rst_n;
  rand bit ena;
  rand bit [7:0] ui_in;
  rand bit [7:0] uio_in;


  bit [7:0] uo_out;
  bit [7:0] uio_out;
  bit [7:0] uio_oe;

	constraint c1{ ui_in[3:0] inside {[0:15]};}



  function new(string name = "seq_item");
    super.new(name);
  endfunction

endclass
