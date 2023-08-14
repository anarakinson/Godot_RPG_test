extends KinematicBody2D


const MAX_SPEED = 80
const ACCELERATION = 500
const FRICTION = 500
const ROLL_MULTIPLIER = 1.5

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var slash_animation_sprite = $HitboxPosition/AnimatedSprite
onready var sword_hitbox = $HitboxPosition/SwordHitbox
onready var hurtbox = $Hurtbox

var stats = PlayerStats
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

enum {
	MOVE,
	ROLL,
	ATTACK
}
var state = MOVE

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree.active = true
	sword_hitbox.knockback_vector = roll_vector
	slash_animation_sprite.visible = false
	stats.connect("no_health", self, "queue_free")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		
		ATTACK:
			attack_state(delta)
		
		ROLL:
			roll_state(delta)
	
	velocity = move_and_slide(velocity)


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.y = Input.get_action_strength("player_down") - Input.get_action_strength("player_up")
	input_vector.x = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	input_vector = input_vector.normalized()
#	print(input_vector)
	
	if input_vector != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		animation_state.travel("Run")
		velocity += input_vector * ACCELERATION * delta
		velocity = velocity.clamped(MAX_SPEED) # the same as move_towards
		roll_vector = input_vector
		sword_hitbox.knockback_vector = input_vector
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	if Input.is_action_just_pressed("player_attak"):
		state = ATTACK

	if Input.is_action_just_pressed("player_roll"):
		state = ROLL


func attack_state(delta):
	velocity = Vector2.ZERO
	animation_state.travel("Attack")

func attack_finished():
	state = MOVE
	

func roll_state(delta):
	velocity = roll_vector * MAX_SPEED * ROLL_MULTIPLIER
	hurtbox.monitoring = false
	animation_state.travel("Roll")

func roll_finished():
	velocity = Vector2.ZERO
	hurtbox.monitoring = true
	state = MOVE


func slash_animation_start():
#	slash_animation_sprite.frame = 0
#	slash_animation_sprite.visible = true
	slash_animation_sprite.play("Hit")


func _on_AnimatedSprite_animation_finished():
	slash_animation_sprite.visible = false


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(1.5)
	hurtbox.create_hit_effect()
	print(stats.health)
