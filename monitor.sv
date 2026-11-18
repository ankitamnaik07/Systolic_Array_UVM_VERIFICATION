
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  uvm_analysis_port #(seq_item) mon_port;

  virtual intf vif;
  seq_item t;

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

    forever begin

      @(vif.mon_cb);

      t = seq_item::type_id::create("t");

      t.ena     = vif.mon_cb.ena;
      t.rst_n   = vif.mon_cb.rst_n;
      t.ui_in   = vif.mon_cb.ui_in;
      t.uio_in  = vif.mon_cb.uio_in;
      t.uo_out  = vif.mon_cb.uo_out;
      t.uio_out = vif.mon_cb.uio_out;
      t.uio_oe  = vif.mon_cb.uio_oe;

      mon_port.write(t);

    end

  endtask

endclass

