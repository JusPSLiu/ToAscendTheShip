extends CharacterBody2D




const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const LERP_DECAY_RATE = 8

@export var Legs : Array[AnimatedSprite2D]
@export var Arm : Sprite2D


var ArmAttachmentAnimator : AnimationPlayer
var facingDirection = false
var moving = false
var touchingUpgradeArea : Node2D = null
var movingToUpgrader : bool = false

var armUpgradeTree : Array[String] = ["none", "hammer", "jackhammer"]
var legUpgradeTree : Array[String] = ["none", "trackL", "wheel"]

func _ready() -> void:
	resetUpgrade()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
		# turn arm to camera
	Arm.look_at(get_global_mouse_position());

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
	if movingToUpgrader:
		velocity.x = 0
		position.x = stolenExpDecayFromYT(position.x, touchingUpgradeArea.position.x, 8, delta)
		if (position.x > touchingUpgradeArea.position.x-1 && position.x < touchingUpgradeArea.position.x+1):
			position.x = touchingUpgradeArea.position.x
	elif (Legs.size() > 0):
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
							leg.z_index = -2
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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT):
			if (ArmAttachmentAnimator != null):
				if (event.pressed and !ArmAttachmentAnimator.is_playing()):
					ArmAttachmentAnimator.play("active")
	if event is InputEventKey:
		if (event.is_action_pressed("ui_up")):
			if (touchingUpgradeArea != null):
				touchingUpgradeArea.turn_on()
				movingToUpgrader = true


func entered_upgrade_area(object):
	touchingUpgradeArea = object


func exited_upgrade_area(object):
	if (touchingUpgradeArea == object):
		touchingUpgradeArea = null

func resetUpgrade():
	movingToUpgrader = false
	# apply arm upgrade
	if (GlobalVariables.activeArm > 0):
		if (Arm.get_children().size() != 0):
			if (Arm.get_child(0).scene_file_path != "res://Scenes/Upgrades/"+armUpgradeTree[GlobalVariables.activeArm]+".tscn"):
				Arm.remove_child(Arm.get_child(0))
				addNewArm()
		else:
			addNewArm()
	else: # or remove it. whatever floats ur boat
		if (Arm.get_children().size() != 0):
			Arm.remove_child(Arm.get_child(0))
	
	# apply leg upgrade
	if (GlobalVariables.activeLeg > 0):
		if (Legs.size() != 0):
			if (Legs[0].scene_file_path != "res://Scenes/Upgrades/"+legUpgradeTree[GlobalVariables.activeLeg]+".tscn"):
				while (Legs.size() > 0):
					remove_child(Legs[0])
					Legs.pop_front()
				addNewLeg()
		else:
			addNewLeg()
	else: # or remove it. whatever floats ur boat
		if (Legs.size() != 0):
			while (Legs.size() > 0):
				remove_child(Legs[0])
				Legs.pop_front()

func addNewArm():
	var newArm = load("res://Scenes/Upgrades/"+armUpgradeTree[GlobalVariables.activeArm]+".tscn")
	Arm.add_child(newArm.instantiate())
	ArmAttachmentAnimator = Arm.get_child(0).get_child(0)

func addNewLeg():
	var newLeg = load("res://Scenes/Upgrades/"+legUpgradeTree[GlobalVariables.activeLeg]+".tscn")
	var leggy = newLeg.instantiate()
	add_child(leggy)
	Legs.append(leggy)
	if (legUpgradeTree[GlobalVariables.activeLeg].ends_with("L")):
		newLeg = load("res://Scenes/Upgrades/"+legUpgradeTree[GlobalVariables.activeLeg]+"R.tscn")
		leggy = newLeg.instantiate()
		add_child(leggy)
		Legs.append(leggy)
		facingDirection = false
