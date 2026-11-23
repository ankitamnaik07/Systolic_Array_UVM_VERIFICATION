class c_27_1;
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

program p_27_1;
    c_27_1 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "xxx00xxzz00z10x10z1z1xzx100x11zxzxzxzzzxxxzxxzxxzzxzzxzxzxxzxzxx";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
