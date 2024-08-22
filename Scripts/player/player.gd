extends CharacterBody2D




const JUMP_VELOCITY = -400.0
const LERP_DECAY_RATE = 8
const COYOTE_MAX = 0.14

@export var Legs : Array[AnimatedSprite2D]
@export var Arm : Sprite2D
@export var colliderShape : CollisionShape2D

var coyoteTime = 0.14
var SPEED = 300.0
var ArmAttachmentAnimator : AnimationPlayer
var facingDirection = false
var moving = false
var jumpable = false
var touchingUpgradeArea : Node2D = null
var movingToUpgrader : bool = false

var armUpgradeTree : Array[String] = ["none", "hammer", "jackhammer"]
var legUpgradeTree : Array[String] = ["none", "trackL", "wheel"]
var legHeight : Array[int] = [39, 42, 50]
var legSpeed : Array[int] = [0, 300, 500]

func _ready() -> void:
	resetUpgrade()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_on_floor():
		coyoteTime = COYOTE_MAX
	else:
		velocity += get_gravity() * delta
		if (coyoteTime > 0):
			coyoteTime -= delta
	
		# turn arm to camera
	Arm.look_at(get_global_mouse_position());

	# Handle go down.
	if (Input.is_action_pressed("ui_down")):
		set_collision_mask_value(2, false)
	else:
		set_collision_mask_value(2, true)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if movingToUpgrader:
		if touchingUpgradeArea == null:
			movingToUpgrader = false
		else:
			velocity.x = 0
			position.x = stolenExpDecayFromYT(position.x, touchingUpgradeArea.position.x, 8, delta)
			if (position.x > touchingUpgradeArea.position.x-1 && position.x < touchingUpgradeArea.position.x+1):
				position.x = touchingUpgradeArea.position.x
	else:
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
			# enter the upgrade menu
			if (touchingUpgradeArea != null):
				touchingUpgradeArea.turn_on()
				movingToUpgrader = true
			elif GlobalVariables.activeLeg == 2 and coyoteTime > 0:
				velocity.y = JUMP_VELOCITY
		elif GlobalVariables.activeLeg == 2 and event.is_action_pressed("ui_accept") and coyoteTime > 0:
			#handle jump
			velocity.y = JUMP_VELOCITY


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
			set_collider_size(legHeight[0])
	SPEED = legSpeed[GlobalVariables.activeLeg]

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
	set_collider_size(legHeight[GlobalVariables.activeLeg])



func set_collider_size(sz):
	colliderShape.shape.height = sz
	colliderShape.position.y = sz-legHeight[0]
	position.y -= 4
