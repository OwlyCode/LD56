extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for kopaing in get_children():
		kopaing.waiting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
