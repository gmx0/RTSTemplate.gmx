extends RefCounted
## Persistent subscriptions replace the frame-reset string signal list.
signal event_received(topic: String, payload: Dictionary)
var history: Array[Dictionary] = []

func publish(topic: String, payload: Dictionary = {}) -> void:
	history.append({"topic": topic, "payload": payload.duplicate(true)})
	if history.size() > 100:
		history.pop_front()
	event_received.emit(topic, payload)
