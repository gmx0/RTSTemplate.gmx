extends Node

func run(world, is_host: bool) -> void:
	world.start_match()
	world.paused = true
	var error: Error = world.net.host(24568) if is_host else world.net.join("127.0.0.1",24568)
	if error != OK:
		print("FAIL ENet setup: ",error_string(error))
		get_tree().quit(1)
		return
	if is_host:
		var success := false
		for i in range(150):
			await get_tree().create_timer(0.1).timeout
			var red_held := false
			var blue_held := false
			for u in world.units.values():
				if u.def_id == "core.engineer" and not u.orders.is_empty():
					if u.side == 2:
						red_held = true
					if u.side == 1:
						blue_held = true
			if red_held and not blue_held:
				success = true
				break
		print("PASS host accepts remote-owned order and rejects foreign ownership" if success else "FAIL host did not receive a valid client order")
		await get_tree().create_timer(1).timeout
		world.net.close()
		get_tree().quit(0 if success else 1)
	else:
		await get_tree().create_timer(1.5).timeout
		var red_id := 0
		var blue_id := 0
		for u in world.units.values():
			if u.def_id == "core.engineer":
				if u.side == 1:
					blue_id = u.uid
				else:
					red_id = u.uid
		world.net.submit({"ids":[red_id],"order":{"type":"hold"}})
		world.net.submit({"ids":[blue_id],"order":{"type":"hold"}})
		await get_tree().create_timer(0.6).timeout
		var success: bool = world.net.active and world.units.has(red_id) and not world.units[red_id].orders.is_empty() and world.units[blue_id].orders.is_empty()
		print("PASS client receives authoritative snapshot after order" if success else "FAIL client snapshot replication")
		world.net.close()
		get_tree().quit(0 if success else 1)
