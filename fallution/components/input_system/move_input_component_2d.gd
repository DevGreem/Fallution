extends Node

class_name MoveInputComponent2D

@export var move_component: MoveComponent2D

## First: Negative X
## Second: Positive X
## Third: Negative Y
## Four: Positive Y
@export var action_vector: Array[StringName] = []:
	set(value):
		
		assert(value.size() == 4, "The action_axis array size will be 4!")
		
		action_vector = value

var axis: Vector2 = Vector2.ZERO

func _input(_event: InputEvent) -> void:
	axis = Input.get_vector.callv(action_vector)
	
	move_component.set_direction(axis)
