class c_12_1;
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

program p_12_1;
    c_12_1 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "x1x100z00xx0x0zz1zz0z1z0xx110z01xzzzzxxzxxxzxxzxxzzxzzzxxzzzzxxx";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
