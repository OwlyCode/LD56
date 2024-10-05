extends Node3D


var hit_points = 10

func _physics_process(_delta):
	for body in $Killzone.get_overlapping_bodies():
		body.get_parent().queue_free()
		hit_points -= 1

		if hit_points <= 0:
			queue_free()
			break

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