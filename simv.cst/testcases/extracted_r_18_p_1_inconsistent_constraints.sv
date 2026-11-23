class c_18_1;
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

program p_18_1;
    c_18_1 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "0z00101z0xxz00x010z110001x10x101xzzzzxxxzxxzzzzxzzzxxzzzzzxxzzxx";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
