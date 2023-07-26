extends KinematicBody

#physics
export var moveSpeed: float = 5.0
export var jumpForce: float = 5.0
export var gravity: float = 15.0

#Camera Look
var minLookAngle: float = -90.0
var maxLookAngle: float = 90.0
var lookSensitivity: float = 0.5

#player sprinting properties
var is_sprinting: bool = false
var sprintValue: float = 10.0
var defaultSpeed: float = 5.0

#vectors
var velocity: Vector3 = Vector3()
var mouseDelta: Vector2 = Vector2()
var snap = Vector3.ZERO

#player components
onready var camera = get_node("Camera")
onready var interaction = get_node("Camera/Interaction")
onready var hand = get_node("Camera/Hand")
onready var weapon_manager = get_node("Camera/Weapons")

var jump_counter = 2
#Physics and Pick up Objects
var pickedObject
export var objectPullPower: float = 4.0
# Called when the node enters the scene tree for the first time.
func _ready():
	#hide and lock the mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	OS.window_fullscreen = false
func pickObjects():
	var collider = interaction.get_collider()
	if collider != null and collider is RigidBody:
		pickedObject = collider

func dropObjects():
	if pickedObject != null:
		pickedObject = null


func _physics_process(delta):

	process_movement_inputs(delta)
	process_jump()
	process_movement()
	process_pickdrop()
	process_weapons()
		
func process_movement_inputs(delta):
	#reset the x and z velocity
	velocity.x = 0
	velocity.z = 0
	var input = Vector2()
	#movement inputs
	if Input.is_action_pressed("move_forward"):
		input.y -= 1
	if Input.is_action_pressed("move_backwards"):
		input.y += 1
	if Input.is_action_pressed("move_left"):
		input.x -= 1
	if Input.is_action_pressed("move_right"):
		input.x += 1
	#normalize the input so no faster movement diagonally
	input = input.normalized()
	#get our forward and right directions
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	
	#set the velocity
	velocity.z = (forward*input.y + right * input.x).z * moveSpeed
	velocity.x = (forward*input.y + right * input.x).x * moveSpeed
	
	#apply gravity
	velocity.y -= gravity * delta
	
	#move the player
	velocity = move_and_slide(velocity, Vector3.UP)

func process_jump():
	#jump if jump button is pressed and if our player is also standing on the floor
	if is_on_floor():
		jump_counter = 2
	if Input.is_action_just_pressed("jump") and jump_counter > 0:
		jump_counter -= 1
		velocity.y = jumpForce
		snap = Vector3.ZERO
	else:
		snap = Vector3.DOWN

func process_movement():
	#sprinting mechanic
	if Input.is_action_pressed("Sprint") and is_on_floor():
		is_sprinting = true
		moveSpeed = sprintValue
	elif Input.is_action_just_released("Sprint") and is_sprinting:
		moveSpeed = defaultSpeed
		is_sprinting = false
	#to go back into default movement speed in case of emergency
	if is_on_floor() and not is_sprinting:
		moveSpeed = defaultSpeed

func process_pickdrop():
	#picking up and dropping objects
#	if Input.is_action_just_pressed("pick_up"):
#		pickObjects()
#	if Input.is_action_just_pressed("drop"):
#		dropObjects()
	if Input.is_action_just_pressed("pick_up"):
		if pickedObject == null:
			print("E --> Pick up")
			pickObjects()
		elif pickedObject != null:
			print("E --> Release")
			dropObjects()

	#picking up objects from rayCast to position3D
	if pickedObject != null:
		var a = pickedObject.global_transform.origin
		var b = hand.global_transform.origin
		pickedObject.set_linear_velocity((b-a)*objectPullPower)

func process_weapons():
	if Input.is_action_just_pressed("empty"):
		weapon_manager.change_weapon("Empty")
	if Input.is_action_just_pressed("primary"):
		weapon_manager.change_weapon("Primary")
	if Input.is_action_just_pressed("secondary"):
		weapon_manager.change_weapon("Secondary")
	if Input.is_action_just_released("scroll_up"):
		weapon_manager.change_weapon("Primary")
	if Input.is_action_just_released("scroll_down"):
		weapon_manager.change_weapon("Secondary")
	# Firing
	if Input.is_action_pressed("fire"):
		var current_weapon = weapon_manager.get_current_weapon()
		if current_weapon != null:
			var ammo_in_mag = current_weapon.ammo_in_mag
			weapon_manager.fire()
			if ammo_in_mag == 0:
				weapon_manager.reload()

	if Input.is_action_just_released("fire"):
		weapon_manager.fire_stop()
	
	# Reloading
	if Input.is_action_just_pressed("reload"):
		weapon_manager.reload()

func _input(event):
	#Mouse Movement
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	window_activity()
	#rotate camera along X-Axis
	camera.rotation_degrees -= Vector3(rad2deg(mouseDelta.y),0,0)*lookSensitivity*delta
	#clamp the vertical camera rotation
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	#rotate player along Y-Axis
	rotation_degrees -= Vector3(0, rad2deg(mouseDelta.x), 0) * lookSensitivity*delta
	
	#reset the mouse delta vector
	mouseDelta = Vector2()
	
#to show/hide cursor
func window_activity():
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
