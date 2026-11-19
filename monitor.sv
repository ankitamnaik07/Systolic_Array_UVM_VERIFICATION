class monitor extends uvm_monitor;

  `uvm_component_utils(monitor)

  uvm_analysis_port #(seq_item) mon_port;

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


  // Print Matrix A
  function void print_matrix_a();

    `uvm_info("MONITOR", "========== MATRIX A ==========", UVM_LOW)

    for(int i=0; i<16; i+=4) begin
      `uvm_info("MONITOR",
        $sformatf("%0d  %0d  %0d  %0d",
          matrix_a[i],
          matrix_a[i+1],
          matrix_a[i+2],
          matrix_a[i+3]),
        UVM_LOW)
    end

  endfunction


  // Print Matrix B
  function void print_matrix_b();

    `uvm_info("MONITOR", "========== MATRIX B ==========", UVM_LOW)

    for(int i=0; i<16; i+=4) begin
      `uvm_info("MONITOR",
        $sformatf("%0d  %0d  %0d  %0d",
          matrix_b[i],
          matrix_b[i+1],
          matrix_b[i+2],
          matrix_b[i+3]),
        UVM_LOW)
    end

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


      // Reset matrix counters
      if(!t.rst_n) begin
        a_count = 0;
        b_count = 0;
      end

      // Capture Matrix A
      else if(t.uio_in == 8'h01) begin

        if(a_count < 16) begin
          matrix_a[a_count] = t.ui_in[3:0];
          a_count++;

          if(a_count == 16)
            print_matrix_a();
        end

      end

      // Capture Matrix B
      else if(t.uio_in == 8'h02) begin

        if(b_count < 16) begin
          matrix_b[b_count] = t.ui_in[3:0];
          b_count++;

          if(b_count == 16)
            print_matrix_b();
        end

      end
	    //$display("%b",t.ui_in);
      mon_port.write(t);

    end

  endtask

endclass
