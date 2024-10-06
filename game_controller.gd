extends Node

const LEADER_PACKING_FORCE = 5.0;
const LEADER_FOLLOW_FORCE = 24.0;
const KOPAING_PUSH_BACK = 6.0;
const KOPAING_SPEED = 24.0;

var cactus = preload("res://cactus.tscn")
var spawner = preload("res://kopeng_spawner.tscn")


var kopeng = preload("res://kopeng.tscn")
var flag = preload("res://flag.tscn")

const FLAG_COOLDOWN = 25.0 # 30.0
const CACTUS_COOLDOWN = 1.0 # 30.0

var chunks = [
	[1.0, preload("res://chunks/chunk_borders.tscn"), CACTUS_COOLDOWN],
	[1.0, preload("res://chunks/chunk_left.tscn"), CACTUS_COOLDOWN],
	[1.0, preload("res://chunks/chunk_right.tscn"), CACTUS_COOLDOWN],
	[1.0, preload("res://chunks/chunk_middle.tscn"), CACTUS_COOLDOWN + 0.5],
	[1.0, preload("res://chunks/chunk_dense.tscn"), CACTUS_COOLDOWN + 1.0],
	[0.1, preload("res://chunks/chunk_big.tscn"), CACTUS_COOLDOWN + 1.0]
]

var last_chunk = null

var passed_chunks = 0

func weighted_random(chunks):
	var total = 0.0
	for chunk in chunks:
		total += chunk[0]

	var r = randf() * total

	for chunk in chunks:
		r -= chunk[0]
		if r < 0:
			return chunk

	return chunks[-1]

var cactus_cooldown = CACTUS_COOLDOWN
var flag_cooldown = FLAG_COOLDOWN

var game_over = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.score = 0
	Globals.distance = 0.0
	Globals.score_accumulator = 0
	Globals.game_speed = 12.0
	Globals.flags = 0
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

	if not game_over and not Globals.main_menu:
		Globals.distance += Globals.game_speed * delta

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
	flag_cooldown -= delta;

	if flag_cooldown < cactus_cooldown:
		reset_cactus_cooldown(CACTUS_COOLDOWN)


	if flag_cooldown < 0:
		reset_flag_cooldown()
		reset_cactus_cooldown(CACTUS_COOLDOWN)
		var k = flag.instantiate()
		k.position = Vector3(-5.0, -200, -40)
		get_node("/root/World").add_child(k)


	if cactus_cooldown < 0:
		if passed_chunks >= 8:
			passed_chunks = 0
			var k = spawner.instantiate()
			k.position = Vector3(randf_range(-4.5, 4.5), -200, -40)
			get_node("/root/World").add_child(k)

			reset_cactus_cooldown(CACTUS_COOLDOWN)
		else:
			passed_chunks += 1
			var chunk = weighted_random(chunks)

			while last_chunk == chunk:
				chunk = weighted_random(chunks)

			last_chunk = chunk

			cactus_cooldown = chunk[2]
			reset_cactus_cooldown(cactus_cooldown)

			var k = chunk[1].instantiate()
			k.position = Vector3(0.0, -200, -40)
			get_node("/root/World").add_child(k)


func reset_flag_cooldown():
	flag_cooldown = FLAG_COOLDOWN

func reset_cactus_cooldown(cooldown):
	cactus_cooldown = cooldown / (Globals.game_speed / 12.0)

func refresh_distance_display():
	var template = "AAAm
   XB"

	var ran_dist = str(ceil(Globals.distance / 5)).lpad(4, "0")
	get_node("/root/World/DistanceDisplay").text = template.replace("AAA", ran_dist).replace("B", str(Globals.flags))

func _physics_process(_delta):
	refresh_distance_display()
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
	Globals.game_speed += 3.5
	get_node("/root/World/Camera3D").shake_boost = 2.0