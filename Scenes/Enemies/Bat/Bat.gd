extends KinematicBody2D


export var ACCELERATION = 100
export var MAX_SPEED = 50
export var FRICTION = 100

const death_effect = preload("res://Scenes/Effects/EnemyDeathEffect.tscn")

onready var stats = $Stats
onready var player_detection_zone = $PlayerDetectionZone
onready var animated_sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
onready var soft_collision = $SoftCollision
onready var wander_controller = $WanderController

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO
var rng = RandomNumberGenerator.new()
var timer = Timer.new()
var random_number_x : int
var random_number_y : int

enum {
	IDLE,
	WANDER,
	CHASE
}
var state = IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	timer.connect("timeout", self, "get_random_direction")
	timer.wait_time = 2
	timer.one_shot = false
	add_child(timer)
	timer.start()
	pass # Replace with function body.

func get_random_direction():
	random_number_x = rng.randi_range(-2, 2)
	random_number_y = rng.randi_range(-2, 2)

func create_death_effect():
	var death_effect_instance = death_effect.instance()
	get_parent().add_child(death_effect_instance)
	death_effect_instance.global_position = global_position
	
func seek_player():
	if player_detection_zone.can_see_player():
		state = CHASE
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

##################
# physics process
##################
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
#	print(stats.health)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2(random_number_x, random_number_y), FRICTION * delta)
			seek_player()
			if wander_controller.get_time_left() == 0:
				state = pick_random_state([IDLE, WANDER, WANDER])
				wander_controller.start_wander_timer(rand_range(1, 3))
		
		WANDER:
			seek_player()
			if (wander_controller.get_time_left() == 0 or global_position.distance_to(wander_controller.target_position) <= 5):
				state = pick_random_state([IDLE, WANDER, WANDER])
				wander_controller.start_wander_timer(rand_range(2, 4))
				
			var direction = global_position.direction_to(wander_controller.target_position)
			velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * 10 * delta)
		
		CHASE:
			var player = player_detection_zone.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
#				var direction = global_position.direction_to(player.global_position)
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
				
	animated_sprite.flip_h = velocity.x < 0
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

###############
# signals
###############
func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 120
	stats.health -= area.damage
	hurtbox.create_hit_effect()


func _on_Stats_no_health():
	create_death_effect()
	queue_free()
