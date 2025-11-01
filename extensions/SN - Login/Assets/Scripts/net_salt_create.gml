///net_salt_create([length])
/*
 * Creates a salt, which is a random string of characters.
 *
 * [length]: The amount of characters in the salt, if left out, the salt will be
 *           8 characters long
*/

var salt = "";
var saltLength = 8;
if(argument_count > 0)
{
    saltLength = argument[0];
}

var zero = 48;
var nine = 57;
var A = 65;
var Z = 90;
var a = 97;
var z = 122;
for(var i = 0; i < saltLength; i ++)
{
    salt += ansi_char(choose(irandom_range(A, Z), irandom_range(a, z), irandom_range(zero, nine)));
}
return salt;
