extends Node

@export var levelNum = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func get_to_next_level():
	if ResourceLoader.exists("res://Scenes/Levels/level_"+str(levelNum+1)+".tscn"):
		get_tree().change_scene_to_file("res://Scenes/Levels/level_"+str(levelNum+1)+".tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Screens/Menu.tscn")


func _on_finished_area_body_entered(body: Node2D) -> void:
	print_debug("hi")
	if (body.is_in_group("player")):
		get_to_next_level()
