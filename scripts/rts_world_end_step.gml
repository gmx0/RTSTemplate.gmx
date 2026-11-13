with(obj_player) rts_fog_update(id);
if global.rts_original || global.rts_match_result!="" exit;
var ours,theirs;
ours=0; theirs=0;
with(obj_unit) if unit_objective {
 if unit_owner==global.rts_viewer ours+=1; else theirs+=1;
}
if ours==0 && theirs==0 global.rts_match_result="Draw";
else if ours==0 global.rts_match_result="Defeat";
else if theirs==0 global.rts_match_result="Victory";
