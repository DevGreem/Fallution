@tool
extends InputComponent

class_name InteractWorldInput

@export var interact_action: StringName = "interact_world"

@export var interact_component: InteractComponent2D:
	set(value):
		interact_component = value
		update_configuration_warnings()

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed(interact_action):
		interact_component.interact()

func _get_configuration_warnings() -> PackedStringArray:
	
	var warnings: PackedStringArray = []
	
	if not interact_component:
		warnings.append("InteractWorldInput need a InteractComponent2D connected!")
	
	return warnings
