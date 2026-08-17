class_name RangedWeapon
extends Node3D

# Pump shotgun — Phase 2 ranged stub. Hitscan cone of pellets with distance
# falloff and a long forced "pump" recovery between shots (the ranged echo of
# melee commitment: lethal up close, useless if you panic-fire from afar).

signal fired
signal hit_landed(target: Node, damage: float)

@export var pellet_count: int = 9
@export var damage_per_pellet: float = 8.0
@export var spread_degrees: float = 7.0
@export var max_range: float = 40.0
@export var falloff_start: float = 7.0   # full damage within this range
@export var min_falloff: float = 0.25    # damage multiplier at max_range
@export var pump_time: float = 0.85      # forced delay before the next shot

var _cooldown: float = 0.0
var _owner_body: Node = null

func _ready() -> void:
	_owner_body = _find_owner_body()

func _physics_process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown = max(_cooldown - delta, 0.0)

func can_fire() -> bool:
	return _cooldown <= 0.0

# Fires from `aim`'s global position along its -Z. Returns total damage dealt.
func fire(aim: Node3D) -> float:
	if not can_fire():
		return 0.0
	_cooldown = pump_time
	fired.emit()

	var space := get_world_3d().direct_space_state
	var origin := aim.global_position
	var basis := aim.global_transform.basis
	var total_damage := 0.0
	var dealt: Dictionary = {}  # target -> accumulated damage (one apply per target)

	for i in pellet_count:
		var dir := _spread_direction(basis)
		var query := PhysicsRayQueryParameters3D.create(origin, origin + dir * max_range)
		query.collide_with_bodies = true
		if _owner_body is CollisionObject3D:
			query.exclude = [_owner_body.get_rid()]
		var hit := space.intersect_ray(query)
		if hit.is_empty():
			continue
		var body: Object = hit.get("collider")
		if body == null or not body.is_in_group("damageable") or not body.has_method("apply_damage"):
			continue
		var dist: float = origin.distance_to(hit.get("position"))
		var dmg := damage_per_pellet * _falloff(dist)
		dealt[body] = dealt.get(body, 0.0) + dmg
		total_damage += dmg

	for body: Node in dealt:
		var hit_dir: Vector3 = (body.global_position - origin).normalized()
		body.apply_damage(dealt[body], hit_dir, 0.15)
		hit_landed.emit(body, dealt[body])

	return total_damage

func _spread_direction(basis: Basis) -> Vector3:
	var forward := -basis.z
	var spread := deg_to_rad(spread_degrees)
	var yaw := randf_range(-spread, spread)
	var pitch := randf_range(-spread, spread)
	return forward.rotated(basis.y, yaw).rotated(basis.x, pitch).normalized()

func _falloff(dist: float) -> float:
	if dist <= falloff_start:
		return 1.0
	var t: float = clampf((dist - falloff_start) / (max_range - falloff_start), 0.0, 1.0)
	return lerpf(1.0, min_falloff, t)

func _find_owner_body() -> Node:
	var n: Node = get_parent()
	while n != null:
		if n is CharacterBody3D:
			return n
		n = n.get_parent()
	return null
