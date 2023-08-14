extends Area2D


const hit_effect = preload("res://Scenes/Effects/HitEffect.tscn")

onready var timer = $Timer
var invincible = false setget set_invincible

signal invincibility_started
signal invincibility_ended


func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect():
	var effect = hit_effect.instance()
	var world = get_tree().current_scene
	world.add_child(effect)
	effect.global_position = global_position - Vector2(0, 8)

func _on_Timer_timeout():
	self.invincible = false

func _on_Hurtbox_invincibility_started():
	set_deferred("monitoring", false)

func _on_Hurtbox_invincibility_ended():
	set_deferred("monitoring", true)

