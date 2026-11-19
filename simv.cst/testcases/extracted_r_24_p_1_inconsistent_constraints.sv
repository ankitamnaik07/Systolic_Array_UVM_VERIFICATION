class c_24_1;
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

program p_24_1;
    c_24_1 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "zzzxxx1100x1xz11101zxx1z1zzz00zxzxxxzxzzxzxzxxzxxzxzzxxxxzzzzxzx";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
