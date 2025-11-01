///net_is_username_taken(username)
/*
 * SERVER ONLY
 *
 * Checks is the user name is taken
 *
 * username: The username to check
*/

ini_open("login.ini");
var key = 0;
while(ini_key_exists("users", string(key)))
{
    var user = ini_read_string("users", string(key), "");
    if(user == argument0)
    {
        ini_close();
        return true;
    }
    key += 1;
}
ini_close();
return false;
