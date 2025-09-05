class_name TrailEffect
extends Line2D

@export var length = 50
@export var is_active = false
var point = Vector2()

func _process(_delta):
	if is_active:
		global_position = Vector2(0,0)
		global_rotation = 0
		
		point = get_parent().global_position
		
		add_point(point)
		while get_point_count() > length:
			remove_point(0)
	else:
		# rimuovo tutti i punti
		while get_point_count():
			remove_point(0)
