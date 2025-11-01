///net_register_add_user(username, password, salt)
/*
 * SERVER ONLY
 *
 * Adds a new user to the user file.
 *
 * username: The username of the new user
 * password: The password of the new user
 * salt: The salt that the password is salted with
*/

ini_open("login.ini");
var key = 0;
while(ini_key_exists("users", string(key)))
{
    key += 1;
}
ini_write_string("users", string(key), argument0);
ini_write_string("passwords", string(key), argument1);
ini_write_string("salts", string(key), argument2);
ini_close();
