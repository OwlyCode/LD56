extends Node3D

var triggered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child.is_in_group("Kopaing"):
			child.waiting = true;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if triggered:
		return

	var parent = body.get_parent()

	if parent.is_in_group("Kopaing"):
		if parent.waiting == false:
			triggered = true
			var leaders = get_tree().get_nodes_in_group("Leader")

			for child in get_children():
				if child.is_in_group("Kopaing"):
					child.waiting = false;
					var pos = child.global_position
					remove_child(child)
					get_node("/root/World").add_child(child)
					print(leaders[0].current_leader)
					if leaders[0].current_leader != null:
						leaders[0].current_leader.add_follower(child)
					child.global_position = pos

			get_node("/root/World/Weepee").play("weepee")

			#queue_free()
