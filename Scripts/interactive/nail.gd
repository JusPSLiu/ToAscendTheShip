extends Node2D

@export var fallingRegion : TileMapLayer
@export var hitbox : Area2D
@export var nail : RigidBody2D
@export var nailSprite : Sprite2D
@export var soundPlayer : AudioStreamPlayer2D
@export var fallingDistance : int = 2

var active : bool = false
var falling : bool = false
var currFallSpeed : float = 0

var startPos : Vector2
var startFallerPos : Vector2

func _ready() -> void:
	fallingDistance *= 32
	startPos = nail.position
	startFallerPos = fallingRegion.position
	nail.process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	if (falling):
		currFallSpeed += delta*10
		fallingRegion.position.y += currFallSpeed
		if (fallingRegion.position.y > startFallerPos.y+fallingDistance):
			fallingRegion.position.y = startFallerPos.y+fallingDistance
			falling = false

func _on_hitbox_area_entered(area: Area2D) -> void:
	if (area.is_in_group("active_hit") and !active):
		active = true
		falling = true
		nail.process_mode = Node.PROCESS_MODE_PAUSABLE
		nail.linear_velocity.x = -100
		nail.z_index = -1
		nailSprite.texture = load("res://Art/interactive/nail.png")
		soundPlayer.play()

func reset():
	position = startPos
	fallingRegion.position = startFallerPos
