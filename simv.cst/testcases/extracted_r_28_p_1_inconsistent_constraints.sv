class c_28_1;
    rand bit[7:0] ui_in; // rand_mode = ON 

    constraint c1_this    // (constraint_mode = ON) (seq_item.sv:16)
    {
       (ui_in inside {[0:15]});
    }
    constraint WITH_CONSTRAINT_this    // (constraint_mode = ON) (sequences.sv:434)
    {
       ((ui_in[7:4]) == 4'hf);
    }
endclass

program p_28_1;
    c_28_1 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "x1zz1zx10x1zz0010z0xzxzz01x10z10zzzxxxzzzxxzxxxzzzzxxxzzzzxzzxxz";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
