if argument0 {global.rts_test_passed+=1; return true;}
global.rts_test_failed+=1;
show_debug_message("FAIL: "+string(argument1));
return false;
