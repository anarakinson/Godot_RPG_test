extends Node2D


const grass_effect = preload("res://Scenes/Effects/GrassEffect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func create_grass_effect():
	var grass_effect_instance = grass_effect.instance()
	get_parent().add_child(grass_effect_instance)
	grass_effect_instance.global_position = global_position


func _on_Hurtbox_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	create_grass_effect()
	queue_free()
