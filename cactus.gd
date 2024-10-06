extends Node3D


var hit_points = 10

func _physics_process(_delta):
	for body in $Killzone.get_overlapping_bodies():
		if body.get_parent().waiting:
			continue

		body.get_parent().call("die")
		hit_points -= 1

		if hit_points <= 0:
			queue_free()
			break
