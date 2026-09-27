@tool
extends Node

class_name InteractInputComponent2D

@export var input_name: StringName
@export var interact_component: InteractComponent2D

func _input(event: InputEvent) -> void:
	
	if Engine.is_editor_hint():
		return
	
	if event.is_action_pressed(input_name):
		interact_component.interact()

func _validate_property(property: Dictionary) -> void:
	
	if property.name == "input_name":
		property.hint = PropertyHint.PROPERTY_HINT_ENUM_SUGGESTION
		property.hint_string = ",".join(InputMap.get_actions())
