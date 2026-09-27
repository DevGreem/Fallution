@icon("res://addons/at-icons/node2d/arrows_counterclockwise.svg")
extends Node

class_name FallRotationComponent2D

@export var actor: CharacterBody2D

@export_range(-360, 360, 1, "or_greater", "or_less", "prefer_slider", "suffix:deg/s^2", "radians_as_degrees")
var rotation_speed: float = 0.0

func _physics_process(delta: float) -> void:
	
	if not actor:
		return
	
	
	if actor.is_on_floor():
		return
	
	var final_rotation := rotation_speed * delta
	
	actor.rotation += final_rotation
