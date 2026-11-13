extends Node
## ENet replaces SimpleNetwork transport. Only server simulates; clients send intent.
signal status_changed(message: String)
var world
var peers: Dictionary = {}
var accumulator := 0.0
var port := 24680
var snapshots_received := 0

func _ready() -> void:
	multiplayer.peer_disconnected.connect(_peer_left)
	multiplayer.peer_connected.connect(_peer_joined)
	multiplayer.connected_to_server.connect(func(): status_changed.emit("Connected to host"))
	multiplayer.connection_failed.connect(func(): close(); status_changed.emit("Connection failed"))
	multiplayer.server_disconnected.connect(func(): close(); world.paused = true; status_changed.emit("Host disconnected; simulation paused"))

func active() -> bool:
	return multiplayer.multiplayer_peer is ENetMultiplayerPeer

func authority() -> bool:
	return not active() or multiplayer.is_server()

func host() -> Error:
	close()
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(port, 1)
	print("ENet host result: ", error_string(error))
	if error == OK:
		multiplayer.multiplayer_peer = peer
		world.local_player = 1
		status_changed.emit("Hosting on UDP %s · player 1" % port)
	return error

func join(address: String) -> Error:
	close()
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, port)
	print("ENet client result: ", error_string(error))
	if error == OK:
		multiplayer.multiplayer_peer = peer
		world.local_player = 2
		world.selected.clear()
		status_changed.emit("Connecting to %s…" % address)
	return error

func close() -> void:
	if active():
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	peers.clear()

func _peer_joined(peer_id: int) -> void:
	print("ENet peer connected: ", peer_id)
	if multiplayer.is_server():
		peers[peer_id] = 2
		assign_player.rpc_id(peer_id, 2)
		apply_snapshot.rpc_id(peer_id, world.serialize())
		status_changed.emit("Player 2 connected")

func _peer_left(peer_id: int) -> void:
	peers.erase(peer_id)
	status_changed.emit("Peer disconnected")

func submit(command: Dictionary) -> void:
	if authority():
		command_feedback(world.execute_command(world.local_player, command))
	elif multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		request_command.rpc_id(1, command)
	else:
		status_changed.emit("Wait for the connection to complete.")

@rpc("any_peer", "call_remote", "reliable")
func request_command(command: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	if peers.has(sender) and JSON.stringify(command).length() < 16000:
		command_feedback.rpc_id(sender, world.execute_command(int(peers[sender]), command))

@rpc("authority", "call_remote", "reliable")
func command_feedback(result: Dictionary) -> void:
	world.last_command_result = result
	if result.code != "accepted":
		status_changed.emit(str(result.code).replace("_", " ").capitalize())

@rpc("authority", "call_remote", "reliable")
func assign_player(id: int) -> void:
	world.local_player = id
	world.camera.position = Vector2(1700, 1000) if id == 2 else Vector2(350, 360)

@rpc("authority", "call_remote", "reliable")
func apply_snapshot(snapshot: Dictionary) -> void:
	snapshots_received += 1
	world.restore(snapshot, true)

func _process(delta: float) -> void:
	if not active() or not multiplayer.is_server():
		return
	accumulator += delta
	if accumulator >= 0.15:
		accumulator = 0
		if not peers.is_empty():
			apply_snapshot.rpc(world.serialize())
