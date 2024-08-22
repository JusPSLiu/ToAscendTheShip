extends CanvasLayer

@export var dialogueSounds : AudioStreamPlayer
@export var text : Label
@export var lettersPerSecond : float
@export var currentDialogue : int
@export var SpeakerImage : ColorRect
@export var SpeakerName : Label
@export var player : CharacterBody2D
@export var CutsceneAnimator : AnimationPlayer

@export_multiline var dialogue : Array[String]

var textCurrentlyDisplayed : float
var loadingIn : bool
var speaking : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	start_dialogue()
	get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# if still loading in, then make the visible characters go up
	if (loadingIn):
		textCurrentlyDisplayed += delta
		text.set_visible_characters(round(textCurrentlyDisplayed*lettersPerSecond))
		if (text.visible_characters >= text.get_total_character_count()):
			loadingIn = false

func setSpeaker(speaker):
	match(speaker.to_lower()):
		'p':
			SpeakerName.text = "1734"
			SpeakerImage.color = Color(0.877, 0.798, 0)
			dialogueSounds.set_stream(load("res://Audio/sfx/talk/player.wav"))
			dialogueSounds.play()
		'b':
			SpeakerName.text = "6732"
			SpeakerImage.color = Color(0.804, 0.384, 0.059)
			dialogueSounds.set_stream(load("res://Audio/sfx/talk/boss.wav"))
			dialogueSounds.play()
		'f':
			SpeakerName.text = "1476"
			SpeakerImage.color = Color(0.51, 0.85, 0)
			dialogueSounds.set_stream(load("res://Audio/sfx/talk/fren.wav"))
			dialogueSounds.play()
		_:
			SpeakerImage.color = Color(0, 0, 0)
	if (speaker == speaker.to_lower()):
		CutsceneAnimator.play(str(currentDialogue))

func changeCurrentDialogue(index):
	if (index < dialogue.size() and dialogue[index] != "/"):
		#tell process that it's loading in
		loadingIn = true
		#reset the visibility
		text.visible_characters = 0
		textCurrentlyDisplayed = 0
		text.text = dialogue[index].substr(1)
		setSpeaker(dialogue[index].substr(0,1))
	else:
		text.get_parent().hide()
		get_tree().paused = false
		speaking = false

func _input(event : InputEvent):
	if (speaking):
		if ((event is InputEventKey and event.is_action_released("ui_accept")) or (event is InputEventMouseButton and event.is_action_released("clicky"))):
			if (loadingIn):
				textCurrentlyDisplayed = text.visible_characters * 0.4
			else:
				changeCurrentDialogue(currentDialogue)
				currentDialogue += 1

func start_dialogue():
	text.get_parent().show()
	speaking = true
	SpeakerImage.show()
	changeCurrentDialogue(currentDialogue)
	currentDialogue += 1


func _on_end_area_entered(area):
	player.disable_children()
	show()
	if (!speaking):
		if (area.is_in_group("player")):
			start_dialogue()

func _on_area_entered(area, index):
	if (!speaking):
		if (area.is_in_group("player")):
			speaking = true
			player.disable_children()
			show()
			currentDialogue = index
			start_dialogue()

func _on_cutscene_area_entered(body):
	if (!speaking):
		if (body.is_in_group("player")):
			player.disable_children()
			CutsceneAnimator.play("Bossy")
