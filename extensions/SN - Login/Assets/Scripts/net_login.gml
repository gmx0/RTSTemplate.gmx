///net_login(username, password)
/*
 * CLIENT ONLY
 *
 * Gets the salt for the user, then tries to log in using the salt.
 *
 * username: The username of the user to log in
 * password: The password of the user to log in
*/

if(instance_exists(obj_login_controller))
{
    with(obj_login_controller)
    {
        user = argument0;
        pass = argument1;
        net_salt_get(user);
        alarm[0] = 1;
    }
}
