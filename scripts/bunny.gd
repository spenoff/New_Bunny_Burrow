extends CharacterBody2D

@onready var dig_cast = $DigCast
@onready var animator = $AnimationPlayer
@export var speed = 1200
@export var jump_speed = -1800
@export var gravity = 4000
@export var is_digging = false

var left_edge_scene = preload("res://scenes/left_edge.tscn")
var right_edge_scene = preload("res://scenes/right_edge.tscn")
var up_edge_scene = preload("res://scenes/up_edge.tscn")
var down_edge_scene = preload("res://scenes/down_edge.tscn")

const DIRT : String = "dirt"
const EDGE : String = "edge"

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
	
func is_dirt(node):
	return node and node.is_in_group(DIRT)
	
func is_edge(node):
	return node and node.is_in_group(EDGE)
	
func destory_dirt(dirt):
	var dirt_pos = dirt.global_position
	dirt.queue_free()
	var up_edge = up_edge_scene.instantiate()
	var down_edge = down_edge_scene.instantiate()
	var right_edge = right_edge_scene.instantiate()
	var left_edge = left_edge_scene.instantiate()
	get_tree().root.add_child(up_edge)
	get_tree().root.add_child(down_edge)
	get_tree().root.add_child(right_edge)
	get_tree().root.add_child(left_edge)
	up_edge.position = dirt_pos
	up_edge.position.y -= 60
	down_edge.position = dirt_pos
	down_edge.position.y += 75
	right_edge.position = dirt_pos
	right_edge.position.x += 65
	left_edge.position = dirt_pos
	left_edge.position.x -= 60
	
func destory_edge(edge):
	if (edge):
		edge.queue_free()
	

# Called when the node enters the scene tree for the first time.
func _ready():
	play_animation(Animations.IDLE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.x = Input.get_axis("left", "right") * speed
	if not is_digging:
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
			
		if Input.is_action_just_pressed("dig"):
			play_animation(Animations.DIG)
			is_digging = true
	else:
		velocity.y = Input.get_axis("up", "down") * speed
		if velocity.x != 0 or velocity.y != 0:
			rotation = lerp_angle(rotation, Input.get_vector("up","down","right","left").angle(), 0.1)
		move_and_slide()
	
		#Check if dig cast collides with dirt
		var dig_cast_colliders = dig_cast.get_overlapping_bodies() 
		for collider in dig_cast_colliders:
			if is_dirt(collider):
				destory_dirt(collider)
			if is_edge(collider):
				destory_edge(collider)
		
	pass 
