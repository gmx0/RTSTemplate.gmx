extends RefCounted
## Godot Vector2 replaces the GM vector scripts. Forces are in pixels/second.
static func seek(point: Vector2, target: Vector2, speed: float) -> Vector2:
	return point.direction_to(target) * speed

static func arrive(point: Vector2, target: Vector2, speed: float, radius: float = 64) -> Vector2:
	return seek(point, target, speed) * minf(point.distance_to(target) / radius, 1)

static func flee(point: Vector2, threat: Vector2, speed: float) -> Vector2:
	return seek(threat, point, speed)

static func pursuit(point: Vector2, target: Vector2, velocity: Vector2, speed: float) -> Vector2:
	return seek(point, target + velocity * minf(point.distance_to(target) / maxf(speed, 1), 2), speed)

static func separation(unit, neighbors: Array) -> Vector2:
	var force := Vector2.ZERO
	for other in neighbors:
		if other == unit or not is_instance_valid(other) or other.dead:
			continue
		var delta: Vector2 = unit.position - other.position
		var radius: float = unit.radius + other.radius + 5
		if delta.length() < radius and delta.length_squared() > 0.01:
			force += delta.normalized() * (1.0 - delta.length() / radius)
	return force

static func alignment(unit, neighbors: Array) -> Vector2:
	var velocity := Vector2.ZERO
	var count := 0
	for other in neighbors:
		if other != unit and other.owner_id == unit.owner_id:
			velocity += other.velocity
			count += 1
	return velocity / maxf(count, 1)

static func cohesion(unit, neighbors: Array) -> Vector2:
	var center := Vector2.ZERO
	var count := 0
	for other in neighbors:
		if other != unit and other.owner_id == unit.owner_id:
			center += other.position
			count += 1
	return unit.position.direction_to(center / count) if count > 0 else Vector2.ZERO

static func wander(angle: float, time: float) -> Vector2:
	return Vector2.from_angle(angle + sin(time * 0.7) * 1.8)

static func path_direction(point: Vector2, path: PackedVector2Array, index: int, loop: bool = true) -> Dictionary:
	if path.is_empty():
		return {"direction": Vector2.ZERO, "index": 0}
	index = clampi(index, 0, path.size() - 1)
	if point.distance_to(path[index]) < 20:
		index = (index + 1) % path.size() if loop else mini(index + 1, path.size() - 1)
	return {"direction": point.direction_to(path[index]), "index": index}
