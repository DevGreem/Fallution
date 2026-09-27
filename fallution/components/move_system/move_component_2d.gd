@icon("res://addons/at-icons/node2d/arrow_cross.svg")
extends Node

class_name MoveComponent2D

signal speed_changed

@export var actor: CharacterBody2D
@export var can_move: bool = true
@export var can_change_direction: bool = true

@export var _speed: float

var speed: float:
	get = _get_speed,
	set = _set_speed

var _direction: Vector2 = Vector2.ZERO

## Read only
var direction: Vector2:
	get: return _direction
	set(value):
		push_error("You can't change the direction value with the \"direction\" property! Use set_direction instead")
		return

func _physics_process(_delta: float) -> void:
	
	if not can_move:
		return
	
	actor.velocity = speed*direction

func set_direction(value: Vector2) -> bool:
	
	if not can_change_direction:
		return false
	
	self._direction = value
	return true

func _get_speed() -> float:
	return _speed

func _set_speed(value: float) -> void:
	if _speed == value:
		return
		
	_speed = value
	speed_changed.emit()
