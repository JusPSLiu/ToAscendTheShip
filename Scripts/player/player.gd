extends CharacterBody2D




const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const LERP_DECAY_RATE = 8

@export var Legs : Array[AnimatedSprite2D]

var facingDirection = false
var moving = false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Handle go down.
	if (Input.is_action_pressed("ui_down")):
		set_collision_mask_value(2, false)
	else:
		set_collision_mask_value(2, true)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = stolenExpDecayFromYT(velocity.x, direction * SPEED, LERP_DECAY_RATE, delta)
		
		#animation :D
		if (facingDirection != (direction < 0)):
			facingDirection = !facingDirection
			for leg in Legs:
				leg.flip_h = facingDirection
				leg.play("move")
				if (Legs.size() > 1):
					if (leg.position.y == Legs[0].front_y):
						leg.position.y = Legs[0].back_y
						leg.z_index = -1
					else:
						leg.position.y = Legs[0].front_y
						leg.z_index = 0
		elif !moving: # if legs arent moving, move them
			moving = true
			for leg in Legs:
				leg.play("move")
	else:
		velocity.x = stolenExpDecayFromYT(velocity.x, 0, LERP_DECAY_RATE, delta)
		if moving: # if legs are moving, stop them
			moving = false
			for leg in Legs:
				leg.play("stand")

	move_and_slide()

# i saw a yt video by freya holmer abt this being a better lerp for this sort of scenario
func stolenExpDecayFromYT(a, b, decay, dt):
	return b+(a-b)*exp(-decay*dt)
