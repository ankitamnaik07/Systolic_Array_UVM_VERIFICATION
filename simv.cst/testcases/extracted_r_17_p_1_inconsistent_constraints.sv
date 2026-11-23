class c_17_1;
    rand bit[7:0] ui_in; // rand_mode = ON 

    constraint c1_this    // (constraint_mode = ON) (seq_item.sv:16)
    {
       (ui_in inside {[0:15]});
    }
    constraint WITH_CONSTRAINT_this    // (constraint_mode = ON) (sequences.sv:428)
    {
       ((ui_in[7:4]) == 4'hf);
    }
endclass

program p_17_1;
    c_17_1 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "z010x1x1zz0z00x1z010z1z1z1zxx0z1xxxxxzxzxxxxxxxzxxzzzxzzzzzxxxxx";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
