extends Sprite2D

@export var newCover : Sprite2D
@export var animationplayer: AnimationPlayer
@export var upgradeType : int = 0 # 0 is legs, 1 is arms
@export var upgradeLevel : int = 1
@export var upgradeMenu : CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match(upgradeType):
		0:
			if GlobalVariables.unlockedLeg >= upgradeLevel:
				newCover.hide()
		1:
			if GlobalVariables.unlockedArm >= upgradeLevel:
				newCover.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.entered_upgrade_area(self)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.exited_upgrade_area(self)

func turn_on():
	animationplayer.play("closedoor")
	await animationplayer.animation_finished
	if (newCover.visible):
		newCover.hide()
		GlobalVariables.unlockedArm = upgradeLevel
	upgradeMenu.openUp()
	animationplayer.play("opendoor")
