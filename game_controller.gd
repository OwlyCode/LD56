extends Node

const LEADER_PACKING_FORCE = 5.0;
const LEADER_FOLLOW_FORCE = 12.0;
const KOPAING_PUSH_BACK = 6.0;
const KOPAING_SPEED = 12.0;

var cactus = preload("res://cactus.tscn")
var spawner = preload("res://kopeng_spawner.tscn")

var chunks = [
	preload("res://chunks/chunk_borders.tscn"),
	preload("res://chunks/chunk_left.tscn"),
	preload("res://chunks/chunk_right.tscn"),
	preload("res://chunks/chunk_middle.tscn")
]

var kopeng = preload("res://kopeng.tscn")
var flag = preload("res://flag.tscn")

const FLAG_COOLDOWN = 30.0 # 30.0
const CACTUS_COOLDOWN = 1.0 # 30.0
const KOPENG_COOLDOWN = 12.0 # 30.0

var cactus_cooldown = CACTUS_COOLDOWN
var kopeng_cooldown = KOPENG_COOLDOWN
var flag_cooldown = FLAG_COOLDOWN

var game_over = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.score = 0
	Globals.score_accumulator = 0
	Globals.game_speed = 12.0
	if not Globals.main_menu:
		get_node("/root/World/StartScreen").hide()


func display_score(delta):
	var template = "[font_size=45][right]000500[/right][/font_size]"
	var accumulator_template = "[font_size=45][right][pulse freq=6][color=47f641]+1000[/color][/pulse][/right][/font_size]";

	if Globals.score_accumulator_cooldown > 0.0:
		template += accumulator_template.replace("1000", str(Globals.score_accumulator))
		Globals.score_accumulator_cooldown -= delta
	else:
		var take = 10

		if Globals.score_accumulator < take:
			take = Globals.score_accumulator

		Globals.score += take
		Globals.score_accumulator -= take

	var score_text = get_node("/root/World/Score")
	score_text.bbcode_text = template.replace("000500", str(Globals.score).lpad(5, "0"))


func detect_gameover():
	var kopaings = get_tree().get_nodes_in_group("Kopaing")

	if kopaings.is_empty():

		var gameover = get_node("/root/World/GameOver")

		gameover.show()

		get_node("/root/World/Music").pitch_scale = 0.5

		game_over = true


func _on_start_button_up():
	Globals.main_menu = false
	get_node("/root/World/StartScreen").hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	detect_gameover()
	display_score(delta)

	var movings = get_tree().get_nodes_in_group("Moving")

	for moving in movings:
		moving.position.z += Globals.game_speed * delta

		if "ttl" in moving and moving.position.z > moving.ttl:
			moving.queue_free()
		elif moving.position.z > 10.0:
			moving.queue_free()

	if game_over or Globals.main_menu:
		return

	cactus_cooldown -= delta;
	kopeng_cooldown -= delta;
	flag_cooldown -= delta;

	if cactus_cooldown < 0:
		var chunk = chunks[randi() % chunks.size()]

		cactus_cooldown = CACTUS_COOLDOWN
		var k = chunk.instantiate()
		k.position = Vector3(0.0, -200, -40)
		get_node("/root/World").add_child(k)

	if kopeng_cooldown < 0:
		kopeng_cooldown = KOPENG_COOLDOWN
		var k = spawner.instantiate()
		k.position = Vector3(randf_range(-4.5, 4.5), -200, -40)
		get_node("/root/World").add_child(k)

	if flag_cooldown < 0:
		flag_cooldown = FLAG_COOLDOWN
		var k = flag.instantiate()
		k.position = Vector3(-5.0, -200, -40)
		get_node("/root/World").add_child(k)


func _physics_process(_delta):
	var kopaings = get_tree().get_nodes_in_group("Kopaing")
	var leaderless = []
	var most_advanced = null;

	for kopaing in kopaings:
		if kopaing.leader == null && kopaing.is_available():
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


func faster():
	Globals.game_speed += 5.0
	get_node("/root/World/Camera3D").shake_boost = 2.0