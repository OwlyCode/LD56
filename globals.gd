extends Node

var main_menu = true

var score = 0
var score_accumulator = 0
var score_accumulator_cooldown = 0.0

var game_speed = 12.0


func camera_shake(intensity = 1, duration = 1):
	var camera = get_node("/root/game/Camera3D")

	for i in range(duration):
		camera.position.x += intensity
		camera.position.y += intensity
		await get_tree().create_timer(0.1).timeout
		camera.position.x -= intensity
		camera.position.y -= intensity
		await get_tree().create_timer(0.1).timeout