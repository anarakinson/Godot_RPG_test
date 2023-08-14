extends Node2D


export(int) var wander_range = 32

onready var start_position = global_position
onready var target_position = global_position
onready var timer = $Timer


func _ready():
	update_target_position()
	
func get_time_left():
	return timer.time_left
	
func start_wander_timer(duration):
	timer.start(duration)

func update_target_position():
	var random_x = rand_range(-wander_range, wander_range)
	var random_y = rand_range(-wander_range, wander_range)
	var target_vector = Vector2(random_x, random_y)
	target_position = start_position + target_vector

func _on_Timer_timeout():
	update_target_position()
