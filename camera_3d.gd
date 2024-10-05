extends Camera3D

# var speed = 12.0

func _process(delta: float) -> void:
	# if Input.is_action_pressed("forward"):
	# 	position.z -= speed * delta
	# if Input.is_action_pressed("backward"):
	# 	position.z += speed * delta
	# if Input.is_action_pressed("left"):
	# 	position.x += speed * delta
	# if Input.is_action_pressed("right"):
	# 	position.x -= speed * delta


	var k = get_tree().get_nodes_in_group("Kopaing")


	print(len(k))

	$Cylinder.rotation_degrees.x += 180.0 * delta
