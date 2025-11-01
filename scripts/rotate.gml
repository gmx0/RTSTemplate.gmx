/*
rotate(angle,dir,rotspeed)
Rotates angle smoothly towards dir with the given speed.

angle - Angle to rotate
dir - The angle to turn to
rotspeed - Rotating speed

Script by Fede-lasse, and icuurd2358972 for sin() help
*/
if (argument0=argument1+180) or (argument0=argument1-180)
return ((argument0+choose(0.1,-0.1))+(sin(degtorad(argument1-argument0))*argument2));
return (argument0+(sin(degtorad(argument1-argument0))*argument2));
