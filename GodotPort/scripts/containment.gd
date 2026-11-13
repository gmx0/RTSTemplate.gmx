extends RefCounted
## Reservations stay on passengers; stored passengers remain serializable entities.

static func compatible(passenger, host) -> bool:
	return host != null and passenger != host and not host.dead and not passenger.dead and passenger.owner_id == host.owner_id and host.host_id == 0 and passenger.host_id == 0 and not passenger.is_structure() and not passenger.has_template("storage_transport") and passenger.movement_layer() in host.stats.get("passenger_layers", ["land"]) and host.has_template("storage_transport") and host.construction >= 1

static func occupied(host) -> int:
	var count := 0
	for unit in host.world.units:
		if not unit.dead and (unit.host_id == host.net_id or unit.reserved_host_id == host.net_id):
			count += int(unit.stats.get("transport_slots", 1))
	return count

static func reserve(passenger, host) -> bool:
	if not compatible(passenger, host):
		return false
	var existing := int(passenger.stats.get("transport_slots", 1)) if passenger.reserved_host_id == host.net_id else 0
	if occupied(host) - existing + int(passenger.stats.get("transport_slots", 1)) > int(host.stats.get("capacity", 0)):
		return false
	passenger.reserved_host_id = host.net_id
	return true

static func board(passenger, host) -> bool:
	if passenger.reserved_host_id != host.net_id or not reserve(passenger, host):
		return false
	passenger.host_id = host.net_id
	passenger.reserved_host_id = 0
	passenger.commands.clear()
	passenger.target_id = 0
	passenger.velocity = Vector2.ZERO
	passenger.position = host.position
	passenger.state = "contained"
	host.world.set_selection(host.world.selected.filter(func(u): return u != passenger))
	return true

static func unload(host) -> int:
	var released := 0
	for passenger in host.world.units.duplicate():
		if passenger.host_id != host.net_id:
			continue
		var point: Vector2 = host.production_exit(passenger.definition_id)
		if not point.is_finite():
			continue
		passenger.host_id = 0
		passenger.position = point
		passenger.state = "idle"
		passenger.commands.clear()
		released += 1
	return released

static func detach(host, destroyed: bool) -> void:
	unload(host)
	for passenger in host.world.units.duplicate():
		if passenger.reserved_host_id == host.net_id:
			passenger.reserved_host_id = 0
			passenger.commands.clear()
		if passenger.host_id == host.net_id:
			# No legal exit: ordinary death cleanup, never stack through blockers.
			if destroyed:
				passenger.host_id = 0
				passenger.dead = true
				host.world.remove_unit(passenger)
