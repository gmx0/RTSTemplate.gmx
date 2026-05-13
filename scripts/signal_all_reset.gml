//Resets the signals every Begin Step

signal_exists();
ds_list_clear(global.signal_list);

//ORDER AS FOLLOWS
//signal() = Step or wherever, as long it isn't the Begin or End Step event
//signal_receive() = Emd Step
//signal_all_reset() = Begin Step

