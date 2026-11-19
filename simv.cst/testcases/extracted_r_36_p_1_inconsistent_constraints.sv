class c_36_1;
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

program p_36_1;
    c_36_1 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "01x00xzx0zzx1111111110zx1xzzxxx1xxzzzzxxzxzxzxxxzzxxxxxxxzzzxzxz";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
