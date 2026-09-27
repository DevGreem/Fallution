extends InputComponent

class_name CloseUIInput

@export var ui: Control

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_close_dialog"):
		UIManager.close(ui)
