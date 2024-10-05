extends Node

const LEADER_PACKING_FORCE = 5.0;
const LEADER_FOLLOW_FORCE = 12.0;
const KOPAING_PUSH_BACK = 6.0;
const KOPAING_SPEED = 12.0;

var cactus = preload("res://cactus.tscn")

var cooldown = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cooldown -= delta;

	if cooldown < 0:
		cooldown = 2.0
		var k = cactus.instantiate()
		k.position = Vector3(randf_range(-4.5, 4.5), -200, -40)
		get_tree().root.add_child(k)

func _physics_process(delta):
	var kopaings = get_tree().get_nodes_in_group("Kopaing")
	var leaderless = []
	var most_advanced = null;

	for kopaing in kopaings:
		if kopaing.leader == null:
			if most_advanced == null or kopaing.position.z < most_advanced.position.z:
				most_advanced = kopaing
			leaderless.append(kopaing)

	for kopaing in leaderless:
		if kopaing == most_advanced:
			continue


		most_advanced.add_follower(kopaing)

# const CELL_SIZE = 1.5

# func get_cell(neighborhood, position):
# 	var x = round(position.x * CELL_SIZE)
# 	var z = round(position.z * CELL_SIZE)

# 	return neighborhood.get_or_add(x, {}).get_or_add(z, []);

# func set_cell(neighborhood, kopaing):
# 	for dx in [-1, 0, 1]:
# 		for dz in [-1, 0, 1]:
# 			var x = round((kopaing.position.x + dx) / CELL_SIZE)
# 			var z = round((kopaing.position.z + dz) / CELL_SIZE)

# 			var cell = neighborhood.get_or_add(x, {}).get_or_add(z, [])
# 			cell.append(kopaing)

# func _physics_process(delta):
# 	var leaders = get_tree().get_nodes_in_group("Leader")

# 	if leaders.is_empty():
# 		return

# 	var leader = leaders[0]

# 	var next_kopaing = []

# 	var neighborhood = {}
# 	for kopaing in self.kopaings:
# 		set_cell(neighborhood, kopaing)

# 	for kopaing in self.kopaings:
# 		if !is_instance_valid((kopaing)):
# 			continue

# 		next_kopaing.append(kopaing)
# 		var movement_wish = Vector3.ZERO
# 		movement_wish = push_back(kopaing, neighborhood, movement_wish, delta)
# 		movement_wish = pack_leader(kopaing, leader, movement_wish, delta)
# 		movement_wish = align_with_leader(kopaing, leader, movement_wish, delta)

# 		kopaing.position += movement_wish


# func push_back(kopaing, neighborhood, movement_wish, delta):
# 	var cell = get_cell(neighborhood, kopaing.position)

# 	var force = Vector3.ZERO

# 	for other in cell:
# 		if !is_instance_valid((kopaing)):
# 			continue

# 		if other == kopaing:
# 			continue

# 		var distance = kopaing.position.distance_to(other.position)

# 		if distance < 0.01:
# 			movement_wish += Vector3.LEFT * KOPAING_PUSH_BACK * delta;
# 			continue

# 		if distance < 1.5:
# 			var direction = (kopaing.position - other.position).normalized()
# 			var power = pow(KOPAING_PUSH_BACK, 0.5 / distance)
# 			force += direction * power * delta;

# 	return movement_wish + force.clampf(-3, 3)

# func pack_leader(kopaing, leader, movement_wish, delta):
# 	var target_position = leader.position + Vector3.BACK * 1.2;

# 	var distance = kopaing.position.distance_to(target_position)

# 	if distance > 1:
# 		var direction = (target_position - kopaing.position).normalized()
# 		movement_wish += direction * LEADER_PACKING_FORCE * delta

# 	return movement_wish

# func align_with_leader(kopaing, leader, movement_wish, delta):
# 	var distance = leader.position.x - kopaing.position.x

# 	movement_wish += Vector3(distance * LEADER_FOLLOW_FORCE * delta, 0, 0)

# 	return movement_wish