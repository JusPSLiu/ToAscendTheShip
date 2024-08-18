extends Node


var currentLevel : int = 1
var numLevels : int = 1
var unlockedLevel : int = 1
var currentPowerup : int = 0

func _ready():
	var save_file = FileAccess.open("user://ship.save", FileAccess.READ)
	if (save_file != null):
		var data = save_file.get_var()
		unlockedLevel = data["L"]
		currentLevel = unlockedLevel
		if currentLevel > numLevels:
			currentLevel = numLevels
		
		#get the textskip, sound volume, and music volume now
		AudioServer.set_bus_volume_db(1, data["s"])
		AudioServer.set_bus_volume_db(2, data["m"])

func give_free_cookies():
	var save_file = FileAccess.open("user://ship.save", FileAccess.WRITE)
	save_file.store_var({
		"L" : unlockedLevel,
		"s" : AudioServer.get_bus_volume_db(1),
		"m" : AudioServer.get_bus_volume_db(2)
	})
	save_file.close()
