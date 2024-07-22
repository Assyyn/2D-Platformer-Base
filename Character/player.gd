extends CharacterBody2D

@export var speed : float = 180.0

@export var jump_velocity: float = -200.0

@export var double_jump_velocity : float = -100

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var has_double_jumped: bool = false
var animation_locked: bool = false
var direction: Vector2 = Vector2.ZERO
var was_in_air: bool = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	else:
		has_double_jumped = false
		
		if was_in_air:
			land()
	
	
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump()
			
		elif not has_double_jumped:
			double_jump()
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left", "right", "down", "up")
	
	if direction and animated_sprite.animation != "jump_end":
		velocity.x = direction.x * speed
		
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	update_facing_direction()
	move_and_slide()
	update_animation()

func update_animation():
	if not animation_locked:
		if direction.x != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")

func update_facing_direction():
	if direction.x > 0:
		animated_sprite.flip_h = false
	if direction.x < 0:
		animated_sprite.flip_h = true

func jump():
	animation_locked = true
	was_in_air = true
	velocity.y = jump_velocity
	animated_sprite.play("jump_start")
	animated_sprite.play("jump_air")

func double_jump():
	# double jump in the air
	velocity.y += double_jump_velocity
	jump()
	has_double_jumped = true

func land():
	animated_sprite.play("jump_end")

func _on_animated_sprite_2d_animation_finished():
	if(animated_sprite.animation == "jump_end"):
		animated_sprite.play("idle")
		animation_locked = false
		was_in_air = false
