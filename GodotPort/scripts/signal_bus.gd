extends RefCounted
## Native notification signal plus the original frame-scoped poll/consume API.
signal broadcast(name: String, payload: Variant, recipient: int)
var pending: Array[Dictionary] = []

func send(name: String, payload: Variant = null, recipient: int = -1) -> void:
	pending.append({"name": name, "payload": payload, "recipient": recipient})
	broadcast.emit(name, payload, recipient)

func receive(name: String, recipient: int = -1, once: bool = false) -> bool:
	for i in range(pending.size()):
		if pending[i].name == name and pending[i].recipient in [-1, recipient]:
			if once:
				pending.remove_at(i)
			return true
	return false

func reset() -> void:
	pending.clear()
