extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


var speed = 6.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("forward"):
		position.z -= speed * delta
	if Input.is_action_pressed("backward"):
		position.z += speed * delta
	if Input.is_action_pressed("left"):
		position.x += speed * delta
	if Input.is_action_pressed("right"):
		position.x -= speed * delta


	$Cylinder.rotation_degrees.x += 180.0 * delta
