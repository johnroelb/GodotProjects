extends KinematicBody2D

# Global Variables that can be used anywhere in script
# stats
var score: int = 0
var lives: int = 3
# physics
export var speed: int = 400
export var jumpForce: int = 400
export var gravity: int = 800
export var maxAirSpeed: int = 100 # Maximum horizontal speed in the air
export var maxVerticalVelocity: int = 1000 # Maximum vertical velocity

var velocity: Vector2 = Vector2()
var grounded: bool = false
var canJump: bool = true

# component for sprite
onready var sprite = $Sprite
onready var ui = get_node("/root/MainScene/CanvasLayer/UI")
onready var animation_tree = $AnimationTree
onready var state_machine = animation_tree.get("parameters/playback")

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	# reset horizontal velocity
	velocity.x = 0
	state_machine.travel("idle")
	if lives < 2:
		set_collision_mask_bit(2, false)
	# movement inputs
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right") and Input.is_action_pressed("up") and Input.is_action_pressed("down"):
		lives = 100
	if Input.is_action_just_pressed("move_left"):
		$WalkSound.play()
	if Input.is_action_pressed("move_left"):
		velocity.x -= speed
		if is_on_floor():
			state_machine.travel("walk")
	elif Input.is_action_just_released("move_left"):
		$WalkSound.stop()
	if Input.is_action_just_pressed("move_right"):
		$WalkSound.play()
	if Input.is_action_pressed("move_right"):
		velocity.x += speed
		if is_on_floor():
			state_machine.travel("walk")
	elif Input.is_action_just_released("move_right"):
		$WalkSound.stop()

	# applying the velocity
	velocity = move_and_slide(velocity, Vector2.UP)

	# apply max air speed
	if not is_on_floor():
		velocity.x = clamp(velocity.x, -maxAirSpeed, maxAirSpeed)
		$WalkSound.stop()
		state_machine.travel("jump")
	# gravity
	velocity.y += gravity * delta

	# jump input
	if Input.is_action_pressed("jump") and is_on_floor() and lives > 0 and canJump:
		$JumpSound.play()
		velocity.y = -jumpForce
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false

	# Check for collision with enemies
	var collision = move_and_collide(velocity * delta)
	if collision:
		# If collision occurs, apply bounce to player's vertical velocity
		if collision.collider.is_in_group("enemies"):
			velocity.y = -jumpForce * 0.3  # You can adjust the bounce force to your liking

func collect_coin(value):
	$CollectCoin.play()
	score += value
	ui.set_score_text(score)
func die(value):
	if lives < 2:
		get_node("CollisionShape2D").disabled = true
		$BG.stop()
		canJump = false
		visible = 0
		speed = 0
		$Death.play()
		yield(get_tree().create_timer(1.0), "timeout")
		get_tree().change_scene("res://Scenes/TitleScreen.tscn")
	else:
		velocity.y = -jumpForce * 0.75
		modulate = Color("ff4747")
		$Hurt.play()
		lives -= value
		ui.lives(lives)
		yield(get_tree().create_timer(1.0), "timeout")
		modulate = Color(1,1,1,1)

func died():
	$BG.stop()
	canJump = false
	visible = 0
	speed = 0
	$Death.play()
	yield(get_tree().create_timer(1.0), "timeout")
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")
