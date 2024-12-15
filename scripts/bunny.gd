extends CharacterBody2D

@onready var animator = $AnimationPlayer
@onready var bunnyCollider = $BunnyCollider
@onready var sprite = $Sprite2D
@export var speed = 1200
@export var jump_speed = -1800
@export var gravity = 4000
@export var dig_buffer_frames = 5 # Number of buffer frames
@export var is_digging = false

var left_edge_scene = preload("res://scenes/left_edge.tscn")
var right_edge_scene = preload("res://scenes/right_edge.tscn")
var up_edge_scene = preload("res://scenes/up_edge.tscn")
var down_edge_scene = preload("res://scenes/down_edge.tscn")

var dig_buffer_counter = 0 # Counter to track the buffer frames
var last_horizontal_direction = 0
var waiting_for_room = false

const DIRT : String = "dirt"
const EDGE : String = "edge"
const DEATH : String = "death"

class Animations:
	const DIG = "dig"
	const WALK = "walk"
	const IDLE = "idle"
	const JUMP = "jump"

func play_animation(animation_name):
	# Set the animation on the AnimationPlayer
	animator.play(animation_name)
	
func queue_animation(animation_name):
	# Queue the animation on the AnimationPlayer
	animator.queue(animation_name)
	
func update_collider_position(horizontal_direction):
	var move_offset = Vector2.ZERO
	if horizontal_direction == -1:
		move_offset.x = -25
	elif horizontal_direction == 1:
		move_offset.x = 25
	
	# Check if we can move the collider without causing a collision
	if move_offset != Vector2.ZERO and not test_move(bunnyCollider.global_transform, move_offset):
		# If there is no collision, move the collider
		waiting_for_room = false
		bunnyCollider.position += move_offset
	else:
		waiting_for_room = true

# Called when the node enters the scene tree for the first time.
func _ready():
	play_animation(Animations.IDLE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("x: ", position.x)
	print("y: ", position.y)
	if waiting_for_room:
		update_collider_position(last_horizontal_direction)
	var horizontal_direction = Input.get_axis("left", "right")
	velocity.x = horizontal_direction * speed
	if Input.is_action_just_pressed("dig"):
		play_animation(Animations.DIG)
		is_digging = true
	if Input.is_action_just_released("dig"):
		is_digging = false

	if is_digging:
		velocity.y = Input.get_axis("up", "down") * speed
		if velocity.x != 0 or velocity.y != 0:
			rotation = lerp_angle(rotation, Input.get_vector("up", "down", "right", "left").angle(), 0.1)
		move_and_slide()

	if not is_digging:
		# Reset rotation to normal
		rotation = lerp_angle(rotation, 0, 0.1)
		
		# Ensure bunny is facing the way they are walkings
		# Check if the character's direction has changed and update the collider position
		if horizontal_direction != last_horizontal_direction:
			update_collider_position(horizontal_direction)
			last_horizontal_direction = horizontal_direction
			
		sprite.flip_h = (last_horizontal_direction == -1)
		
		# Check for jump input
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_speed
			play_animation(Animations.JUMP)
	
		velocity.y += gravity * delta
		move_and_slide()
		
		# Check if the character has landed and is not moving
		if is_on_floor() and velocity.x == 0:
			play_animation(Animations.IDLE)
		elif is_on_floor():
			play_animation(Animations.WALK)
		
	pass 
