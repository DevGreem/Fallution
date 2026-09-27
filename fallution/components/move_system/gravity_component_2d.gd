@icon("res://addons/at-icons/node2d/gravity.svg")
extends GravityComponent

class_name GravityComponent2D

@export var actor: CharacterBody2D

func _physics_process(delta: float) -> void:
	
	if not actor:
		return
	
	if actor.is_on_floor():
		return
	
	actor.velocity += actor.get_gravity() * delta * gravity_effect
