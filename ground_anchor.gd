extends Node

@onready var p = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta):
	# --- Bind to ground
	var space_state = p.get_world_3d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters3D.create(p.global_position + Vector3(0, 1000, 0), p.global_position + Vector3(0, -1000, 0))
	query.collision_mask = 1

	var result = space_state.intersect_ray(query)

	if !result.is_empty():
		p.global_position.y = result.position.y
		p.visible = true
	else:
		p.visible = false