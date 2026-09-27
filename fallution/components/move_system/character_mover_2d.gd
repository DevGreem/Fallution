@icon("res://addons/at-icons/node2d/motion_vector.svg")
extends Node

class_name CharacterMover2D

@export var work_in_editor: bool = false
@export var actor: CharacterBody2D
@export var normal_on_floor: bool = false

func _physics_process(_delta: float) -> void:
	
	if not actor:
		return
	
	if actor.velocity == Vector2.ZERO:
		return
	
	actor.move_and_slide()
	
	if normal_on_floor and actor.is_on_floor():
		var normal := actor.get_floor_normal()
		var target_rotation := normal.angle() + PI/2.0
		
		actor.rotation = target_rotation
