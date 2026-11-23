
class driver extends uvm_driver #(seq_item);

  `uvm_component_utils(driver)

  virtual intf vif;

  function new(string name = "driver",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(virtual intf)::get(
          this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "config db failed")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);

      drive(req);

      seq_item_port.item_done();
    end
  endtask

  task drive(seq_item req);

    // Asynchronous active-low reset
    vif.rst_n = req.rst_n;

    @(vif.drv_cb);

    vif.drv_cb.ena    <= req.ena;
    vif.drv_cb.ui_in  <= req.ui_in;
    vif.drv_cb.uio_in <= req.uio_in;

  endtask

<<<<<<< HEAD
//if(req.uio_in[2]) `uvm_info("START SENT", $sformatf("START = %0d, time = %0t", req.uio_in[2], $time), UVM_NONE)

endtask
=======
>>>>>>> origin/main
endclass

