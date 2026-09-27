@tool
extends InputComponent

class_name MoveInputComponent1D

enum Coords {
	X,
	Y
}

@export var move_component: MoveComponent2D
@export var direction: Coords = Coords.X

@export var negative_action: StringName
@export var positive_action: StringName

func _input(_event: InputEvent) -> void:
	
	if Engine.is_editor_hint():
		return
	
	var coord_axis := Input.get_axis(negative_action, positive_action)
	var axis: Vector2 = move_component.direction
	
	if direction == Coords.X:
		axis.x = coord_axis
		move_component.set_direction(axis)
	else:
		axis.y = coord_axis
		move_component.set_direction(axis)

func _validate_property(property: Dictionary) -> void:
	
	if property.name in ["negative_action", "positive_action"]:
		property.hint = PropertyHint.PROPERTY_HINT_ENUM_SUGGESTION
		property.hint_string = ",".join(InputMap.get_actions())
