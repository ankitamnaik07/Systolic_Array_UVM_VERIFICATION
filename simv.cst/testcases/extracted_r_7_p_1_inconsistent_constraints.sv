class c_7_1;
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

program p_7_1;
    c_7_1 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "z00z01z0x010101z1xx1z1x0x0z1zzxzzxxxxzzzzzzxzzxxzzzxzzzzxzzxxxxz";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
