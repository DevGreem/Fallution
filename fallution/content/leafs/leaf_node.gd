@icon("res://addons/at-icons/node2d/leaf.svg")
extends Node2D

class_name LeafNode

@export var get_leaf_interaction: InteractArea2D
@export var value: float

func _ready() -> void:
	
	get_leaf_interaction.interacted.connect(_on_interact)

func _on_interact(component: InteractComponent2D) -> void:
	
	queue_free()
