//arg0 = val to square root
var __val=argument0;

if __val>90.2
return sqrt_fast(__val*0.01)*10;

if __val<=0.2
return 0;
if __val<=2.2
return 1;
if __val<=6.2
return 2;
if __val<=12.2
return 3;
if __val<=20.2
return 4;
if __val<=30.2
return 5;
if __val<=42.2
return 6;
if __val<=56.2
return 7;
if __val<=72.2
return 8;
if __val<=90.2
return 9;
/*
if __val<=110.2
return 10;
if __val<=132.2
return 11;
if __val<=156.2
return 12;
*/

return sqrt(__val);
