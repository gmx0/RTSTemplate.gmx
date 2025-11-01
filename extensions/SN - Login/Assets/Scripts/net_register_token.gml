///net_register_token(username, token)
/*
 * Sets the token of the user.
 *
 * username: The username of the user
 * token: The users token
*/

ini_open("login.ini");
var key = 0;
while(ini_key_exists("users", string(key)))
{
    var user = ini_read_string("users", string(key), "");
    if(user == argument0)
    {
        ini_write_string("tokens", string(key), argument1);
        ini_close();
        return false;
    }
    key += 1;
}
ini_close();
