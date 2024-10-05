extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

var speed = 12.0

var kopeng = preload("res://kopeng.tscn")

var followers = []
var current_leader = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	var kopaings = get_tree().get_nodes_in_group("Kopaing")

	position.z = max(-len(kopaings) * 0.1, -4.0)

	if Input.is_action_just_pressed("forward") and true:
		#position.z -= speed * delta
		for x in range(1):
			var k = kopeng.instantiate()
			k.position = position + Vector3.BACK * 1.2;
			if current_leader != null:
				current_leader.add_follower(k)

			get_node("/root/World").add_child(k)
	if Input.is_action_pressed("left"):
		position.x -= speed * delta
	if Input.is_action_pressed("right"):
		position.x += speed * delta

	if position.x > 4.5:
		position.x = 4.5
	if position.x < -4.5:
		position.x = -4.5

func _physics_process(_delta):
	var space_state = get_world_3d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters3D.create(position + Vector3(0, 1000, 0), position + Vector3(0, -1000, 0))
	var result = space_state.intersect_ray(query)

	if !result.is_empty():
		position.y = result.position.y
