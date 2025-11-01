///net_login_token([token])
/*
 * CLIENT ONLY
 *
 * Login the user with a token instead of username+password.
 * A token is used when the user wants the program to "remeber" the user. Instead of saving
 * the password on the computer, a token is used instead. A token is a string filled with
 * random characters.
 *
 * [token]: The token to log in with. If unspecified, it will read the token from the
 *          ini file that is created when the user logs in.
*/
var token;
if(argument_count > 0)
{
    token = argument[0];
}
else
{
    ini_open("token.ini");
    token = ini_read_string("token", "0", "");
    ini_close();
}
if(token != "")
{
    net_packet_create("Token");
    net_packet_add(token);
    net_packet_send();
}
