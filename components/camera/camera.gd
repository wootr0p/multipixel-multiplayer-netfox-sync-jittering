class_name LevelCamera
extends Camera2D

@export var follow_speed: float = 8.0 # più alto = segue più velocemente
@export var follow: Node2D

func _physics_process(delta: float) -> void:
	if follow:
		var current_pos = global_position
		var target_pos = follow.global_position
		global_position = current_pos.lerp(target_pos, follow_speed * delta)
