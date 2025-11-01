///net_is_credentials_valid(username, password)
/*
 * SERVER ONLY
 *
 * Checks if the username and password is registrated together.
 *
 * username: The username to check
 * password: The password to check
*/

ini_open("login.ini");
var key = 0;
while(ini_key_exists("users", string(key)))
{
    var user = ini_read_string("users", string(key), "");
    var pass = ini_read_string("passwords", string(key), "");
    if(user == argument0 && pass == argument1)
    {
        ini_close();
        return true;
    }
    key += 1;
}
ini_close();
return false;
