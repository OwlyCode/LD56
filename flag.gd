extends Node3D

var triggered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if triggered:
		return

	var parent = body.get_parent()

	if parent.is_in_group("Kopaing"):
		if parent.waiting == false:
			triggered = true

			var kopaings = get_tree().get_nodes_in_group("Kopaing")
			var score = 0

			for kopaing in kopaings:
				if kopaing.waiting == false:
					score += 100


			Globals.score_accumulator = score
			Globals.score_accumulator_cooldown = 4.0