extends Node3D

var speed = 12.0

var hit_points = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta):
	for body in $Killzone.get_overlapping_bodies():
		body.get_parent().queue_free()
		hit_points -= 1

		if hit_points <= 0:
			queue_free()
			break

	position.z += speed * delta

	var space_state = get_world_3d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters3D.create(position + Vector3(0, 1000, 0), position + Vector3(0, -1000, 0))
	query.collision_mask = 1

	var result = space_state.intersect_ray(query)

	if !result.is_empty():
		position.y = result.position.y
		visible = true
	else:
		visible = false