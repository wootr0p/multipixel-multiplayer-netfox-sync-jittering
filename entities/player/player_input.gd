class_name PlayerInput
extends Node

var input_dir : Vector2
var input_jump : float
var input_dash : float

func _ready() -> void:
	NetworkTime.before_tick_loop.connect(_gather)

func _gather():
	if multiplayer.is_server():
		return
	if not is_multiplayer_authority():
		return
	
	input_dir = Input.get_vector("left", "right", "up", "down")
	input_jump = Input.get_action_strength("jump")
	input_dash = Input.get_action_strength("dash")
