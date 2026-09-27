extends Button

class_name UICloseButton

@export var ui: Control

func _ready() -> void:
	
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

func _on_pressed() -> void:
	UIManager.close(ui)
