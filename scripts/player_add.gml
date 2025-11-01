//array length is +1 the last index, of course
//arg0: player object
//arg1: player side
//arg2: player unit
//arg3: player color
var _new=array_length_1d(global.player);
global.player[_new]=instance_create(0,0,argument0);
global.player[_new].player_side=argument1;
global.player[_new].player_unit=argument2;
global.player[_new].player_color=argument3;

return global.player[_new];
