extends CanvasLayer


@export var previewArmParent : Control
@export var previewLegParent : Control
@export var armHighlighter : Control
@export var legHighlighter : Control
@export var armButtonParent : Control
@export var legButtonParent : Control
@export var buttonSounds : AudioStreamPlayer
@export var player : CharacterBody2D

var previewArms : Array[TextureRect]
var previewLegs : Array[TextureRect]
var armButtons : Array[Control]
var legButtons : Array[Control]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	# set up arm previews and leg previews
	for child in previewArmParent.get_children():
		if (child is TextureRect):
			previewArms.append(child)
	for child in previewLegParent.get_children():
		if (child is TextureRect):
			previewLegs.append(child)
	# set proper leg visible
	for leg in previewLegs:
		leg.hide() # make everything invisible
	var id = GlobalVariables.activeLeg-1
	if (id > -1): previewLegs[id].show()
	legHighlighter.position.x = 387 + (104*id)
	
	# set proper arm visible
	id = GlobalVariables.activeArm-1
	for arm in previewArms:
		arm.hide()
	if (id > -1): previewArms[id].show()
	armHighlighter.position.x = 387 + (104*id)
	
	# set the buttons
	for child in armButtonParent.get_children():
		if (child is Control):
			armButtons.append(child)
	for child in legButtonParent.get_children():
		if (child is Control):
			legButtons.append(child)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func openUp():
	get_tree().paused = true
	
	for i in range(armButtons.size()):
		if (i > GlobalVariables.unlockedArm):
			armButtons[i].hide()
	for i in range(legButtons.size()):
		if (i > GlobalVariables.unlockedArm):
			legButtons[i].hide()
	show()

func close():
	hide()
	get_tree().paused = false
	player.resetUpgrade()

func selectUpgrade(type:int, id:int):
	id -= 1
	match(type):
		0: # type 0 is feet
			if (GlobalVariables.activeLeg != id+1):
				buttonSounds.play()
			GlobalVariables.activeLeg = id+1
			# if not already selected
			if (id < 0 || !previewLegs[id].visible):
				for leg in previewLegs:
					leg.hide() # make everything invisible
				if (id >= 0):
					previewLegs[id].show() #except the proper one
				legHighlighter.position.x = 387 + (104*id)
		1: # type 0 is hands
			if (GlobalVariables.activeArm != id+1):
				buttonSounds.play()
			GlobalVariables.activeArm = id+1
			if (id < 0 || !previewArms[id].visible):
				for arm in previewArms:
					arm.hide() # make everything invisible
				if (id >= 0):
					previewArms[id].show() #except the proper one
				armHighlighter.position.x = 387 + (104*id)
