// AI player context: same admission path as human input, no direct order writes.
// Optional caller-owned script chooses policy; default does nothing.
if player_ai_policy!=noone && script_exists(player_ai_policy) script_execute(player_ai_policy,id);
