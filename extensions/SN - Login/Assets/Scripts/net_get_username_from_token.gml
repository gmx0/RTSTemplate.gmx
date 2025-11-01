///net_get_username_from_token(token)
/*
 * Gives the username that is associated with the given token, or "" if no username is 
 * connected with the given token.
 *
 * token: The token to check for
*/

ini_open("login.ini");
var key = 0;
while(ini_key_exists("tokens", string(key)))
{
    var token = ini_read_string("tokens", string(key), "");
    if(token == argument0)
    {
        var name = ini_read_string("users", string(key), "")
        ini_close();
        return name;
    }
    key += 1;
}
ini_close();
return "";
