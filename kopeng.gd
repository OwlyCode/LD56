extends Node3D

@onready var controller = get_node("/root/World/GameController")

var followers = []
var leader = null

var waiting = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func handle_followers():
	for follower in followers:
		if !is_instance_valid(follower):
			followers.erase(follower)

	if len(followers) > 9:
		var excluded = followers.pop_back()
		# Get random follower and gives it the excluded follower
		var random_follower = followers[randi() % followers.size()]
		random_follower.add_follower(excluded)


func add_follower(follower):
	self.followers.append(follower)
	follower.leader = self

func get_current_leader():
	var current_leader = leader

	$Sprite3D.modulate = Color(1, 1, 1)

	if current_leader == null:
		$Sprite3D.modulate = Color(1, 0, 0)

		var leaders = get_tree().get_nodes_in_group("Leader")

		if leaders.is_empty():
			return null

		current_leader = leaders[0]

	return current_leader

func _physics_process(delta):
	if !waiting:
	# --- Follow the leader!
		if leader != null && !is_instance_valid(leader):
			leader = null;

		handle_followers()

		var movement_wish = Vector3.ZERO

		movement_wish = pack_leader(movement_wish, delta)
		movement_wish = align_with_leader(movement_wish, delta)
		movement_wish = push_back(movement_wish, delta)

		position += movement_wish

	# --- Bind to ground
	var space_state = get_world_3d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters3D.create(position + Vector3(0, 1000, 0), position + Vector3(0, -1000, 0))
	query.collision_mask = 1

	var result = space_state.intersect_ray(query)

	if !result.is_empty():
		position.y = result.position.y
		visible = true
	else:
		visible = false


const LEADER_PACKING_FORCE = 5.0;
const LEADER_FOLLOW_FORCE = 12.0;
const KOPAING_PUSH_BACK = 6.0;
const KOPAING_SPEED = 12.0;

func pack_leader(movement_wish, delta):
	var current_leader = get_current_leader()

	var target_position = current_leader.position + Vector3.BACK * 1.2;

	var distance = position.distance_to(target_position)

	if distance > 1:
		var direction = (target_position - position).normalized()
		movement_wish += direction * LEADER_PACKING_FORCE * delta

	return movement_wish

func align_with_leader(movement_wish, delta):
	var current_leader = get_current_leader()

	var distance = current_leader.position.x - position.x

	movement_wish += Vector3(distance * LEADER_FOLLOW_FORCE * delta, 0, 0)

	return movement_wish

func push_back(movement_wish, delta):
	# var others = get_tree().get_nodes_in_group("Kopaing")

	var others = get_current_leader().followers.duplicate(false) # Shallow copy

	for other in others:
		if other == self:
			continue

		if !is_instance_valid(other):
			continue

		var distance = position.distance_squared_to(other.position)

		if distance < 0.01:
			movement_wish += Vector3.LEFT * KOPAING_PUSH_BACK * delta;
			continue

		if distance < 1.5:
			var direction = (position - other.position).normalized()
			var power = pow(KOPAING_PUSH_BACK, 0.5 / distance)

			power = clamp(power, 0, 3)

			movement_wish += direction * power * delta;

	return movement_wish
