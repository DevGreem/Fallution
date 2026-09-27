extends CharacterBody2D

class_name LeafNode

@export var get_leaf_interaction: InteractArea2D

func _ready() -> void:
	
	get_leaf_interaction.interacted.connect(_on_interact)

func _on_interact(component: InteractComponent2D) -> void:
	
	queue_free()
