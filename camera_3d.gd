extends Camera3D

func _process(delta: float) -> void:
	# print(len(k))
	# for x in k:
	# 	print(x.leader)
	# 	print(x.followers)
	# 	print("---")

	$Cylinder.rotation_degrees.x += 180.0 * delta
