extends Node

const LEADER_PACKING_FORCE = 5.0;
const LEADER_FOLLOW_FORCE = 12.0;
const KOPAING_PUSH_BACK = 6.0;
const KOPAING_SPEED = 12.0;

var cactus = preload("res://cactus.tscn")
var spawner = preload("res://kopeng_spawner.tscn")

var kopeng = preload("res://kopeng.tscn")


var cactus_cooldown = 2.0
var kopeng_cooldown = 10.0
var cta_cooldown = 2.0

var game_speed = 12.0

var game_over = false
var main_menu = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func detect_gameover():
	var kopaings = get_tree().get_nodes_in_group("Kopaing")

	if kopaings.is_empty():

		var gameover = get_node("/root/World/GameOver")

		gameover.show()

		game_over = true

func handle_cta(delta):
	var cta = get_node("/root/World/StartScreen")

	if cta_cooldown < 0 or game_over:
		cta.hide()
	else:
		cta.show()

	if not main_menu:
		cta_cooldown -= delta


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	detect_gameover()
	handle_cta(delta)

	var movings = get_tree().get_nodes_in_group("Moving")

	for moving in movings:
		moving.position.z += game_speed * delta

		if moving.position.z > 10.0:
			moving.queue_free()

	if game_over or main_menu:
		return

	cactus_cooldown -= delta;
	kopeng_cooldown -= delta;

	if cactus_cooldown < 0:
		cactus_cooldown = 2.0
		var k = cactus.instantiate()
		k.position = Vector3(randf_range(-4.5, 4.5), -200, -40)
		get_node("/root/World").add_child(k)

	if kopeng_cooldown < 0:
		kopeng_cooldown = 10.0
		var k = spawner.instantiate()
		k.position = Vector3(randf_range(-4.5, 4.5), -200, -40)
		get_node("/root/World").add_child(k)


func _physics_process(_delta):
	var kopaings = get_tree().get_nodes_in_group("Kopaing")
	var leaderless = []
	var most_advanced = null;

	for kopaing in kopaings:
		if kopaing.leader == null && !kopaing.waiting:
			if most_advanced == null or kopaing.position.z < most_advanced.position.z:
				most_advanced = kopaing
			leaderless.append(kopaing)


	for kopaing in leaderless:
		if kopaing == most_advanced:
			continue

		most_advanced.add_follower(kopaing)
		print("Adding follower " + str(kopaing) + " to " + str(most_advanced))


	var leaders = get_tree().get_nodes_in_group("Leader")

	for leader in leaders:
		leader.current_leader = most_advanced


func _on_button_button_up():
	# reload scene
	get_tree().reload_current_scene()