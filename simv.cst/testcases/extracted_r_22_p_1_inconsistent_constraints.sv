class c_22_1;
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

program p_22_1;
    c_22_1 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "0xzz100zz10x0101z0z0z0010xz0x10xxxxzxzzxzzxxxzzzxzxzxzzzzxzxzxxz";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
