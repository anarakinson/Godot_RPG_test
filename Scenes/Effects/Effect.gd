extends Node2D


onready var animated_sprite = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite.connect("animation_finished", self, "_on_animation_finished")
	animated_sprite.frame = 0
	animated_sprite.play("Animated")


func _on_animation_finished():
	queue_free()
