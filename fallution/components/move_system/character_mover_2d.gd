@icon("res://addons/at-icons/node2d/motion_vector.svg")
extends Node

class_name CharacterMover2D

@export var work_in_editor: bool = false
@export var actor: CharacterBody2D

func _physics_process(_delta: float) -> void:
	
	if actor.velocity == Vector2.ZERO:
		return
	
	actor.move_and_slide()
