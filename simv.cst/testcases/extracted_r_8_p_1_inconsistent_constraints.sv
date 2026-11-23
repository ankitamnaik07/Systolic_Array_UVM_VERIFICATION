class c_8_1;
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

program p_8_1;
    c_8_1 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "1x00zx00x0z0z01zx100z0x10z10x001xzzxxzzxzzxzzzzxzzzzzxxzxzzxxzxx";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
