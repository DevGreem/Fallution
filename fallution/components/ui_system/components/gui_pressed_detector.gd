extends Control

class_name GUIPressedDetector

signal pressed

func _gui_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			pressed.emit()
