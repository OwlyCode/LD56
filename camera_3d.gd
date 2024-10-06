extends Camera3D

var shake_accumulator = Vector3.ZERO

var ellapsed = 0.0

var shake_boost = 0.0

@onready var memorized_position = position;

func _process(delta: float) -> void:
	var kopengs = get_tree().get_nodes_in_group("Kopaing")
	var kopeng_count = 0

	shake_boost -= delta

	ellapsed += delta

	for k in kopengs:
		if k.is_available():
			kopeng_count += 1


	var freq = 1.5 * kopeng_count
	var amp = 0.00025 * kopeng_count

	if amp > 0.006:
		amp = 0.006

	if freq > 36:
		freq = 36

	if shake_boost > 0.0:
		amp += 0.02
		freq += 30

	rotation.z = sin(ellapsed * freq) * amp;

	position = memorized_position + shake_accumulator

	get_node("/root/World/Cylinder").rotation_degrees.x += 45.0 * delta
