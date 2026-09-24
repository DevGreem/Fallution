extends Node

class_name FlipComponent2D

@export var active: bool = true

@export var flip_x: bool = true
@export var flip_y: bool = false

@export var move_component: MoveComponent2D
@export var sprite: Sprite2D

func _process(_delta: float) -> void:
	
	if not active:
		return
	
	if flip_x:
		if move_component.direction.x < 0:
			sprite.flip_h = true
		elif move_component.direction.x > 0:
			sprite.flip_h = false
	
	if flip_y:
		if move_component.direction.y < 0:
			sprite.flip_v = true
		elif move_component.direction.y > 0:
			sprite.flip_v = false
