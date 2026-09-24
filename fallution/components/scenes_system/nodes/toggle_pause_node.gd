extends Node

class_name TogglePauseNode

enum PauseType {
	PAUSE,
	UNPAUSE,
	TOGGLE
}

@export var pause: PauseType = PauseType.PAUSE

func toggle_pause() -> void:
	
	if pause == PauseType.TOGGLE:
		get_tree().paused = !get_tree().paused
		return
	
	get_tree().paused = pause == PauseType.PAUSE
