class monitor extends uvm_monitor;

  `uvm_component_utils(monitor)

  uvm_analysis_port #(seq_item) mon_port;
  int count;
  bit start_asserted;
  virtual intf vif;

  bit [3:0] matrix_a[16];
  bit [3:0] matrix_b[16];

  int a_count = 0;
  int b_count = 0;

  function new(string name = "monitor",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon_port = new("mon_port", this);

    if(!uvm_config_db #(virtual intf)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "config db failed")
  endfunction


  task run_phase(uvm_phase phase);

    seq_item t;

    forever begin

      @(vif.mon_cb);

      t = seq_item::type_id::create("t");

      t.ena     = vif.mon_cb.ena;
      t.rst_n   = vif.rst_n;
      t.ui_in   = vif.mon_cb.ui_in;
      t.uio_in  = vif.mon_cb.uio_in;
      t.uo_out  = vif.mon_cb.uo_out;
      t.uio_out = vif.mon_cb.uio_out;
      t.uio_oe  = vif.mon_cb.uio_oe;
<<<<<<< HEAD
	
	/*if(t.uio_in[2]) `uvm_info("MONITOR", $sformatf("start asserted time = %0t", $time), UVM_NONE)

	if(start_asserted) count++;

	if(t.uio_in[2])begin
		start_asserted = 1;
	end
	
	if(count != 0) begin 
		if(!t.uio_out[4]) `uvm_error("BUSY ERROR", $sformatf("time = %0t", $time))
	end
	
	if(count >= 28)begin 
	 count = 0;
	 start_asserted = 0;
end
*/

//	$display("%b",t.ui_in);
      mon_port.write(t);

=======

	    mon_port.write(t);
>>>>>>> origin/main
    end

  endtask

endclass


