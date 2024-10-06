extends Node3D


var hit_points = 10
var dead = false

func _physics_process(_delta):
	if dead:
		return

	for body in $Killzone.get_overlapping_bodies():
		if body.get_parent().waiting:
			continue

		body.get_parent().call("die")
		hit_points -= 1

		Globals.camera_shake(0.1, 2)

		if hit_points <= 0:
			dead = true
			$Chunks.emitting = true
			$Sprite3D.queue_free()
			$Killzone.queue_free()
			break
