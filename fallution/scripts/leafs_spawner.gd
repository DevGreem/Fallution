extends Area2D

class_name LeafsSpawner

@export var collision: CollisionShape2D
@export var spawn_time: float
@export var spawn_cantity_range: Vector2:
	set(value):
		spawn_cantity_range = value.max(Vector2(0, 0))

const LEAFS_DATABASE: Registry = preload("uid://b5ontlvcp1fft")

func get_random_position() -> Vector2:
	
	var shape: RectangleShape2D = collision.shape
	
	var half_size := shape.size / 2.0
	
	var spawn_point := Vector2(
		randf_range(-half_size.x, half_size.x),
		randf_range(-half_size.y, half_size.y)
	)
	
	return collision.to_global(spawn_point)

func spawn_leaf(leaf: LeafInfo) -> void:
	
	var node: LeafNode = leaf.scene.instantiate()
	
	var pos := get_random_position()
	
	node.global_position = pos
	add_child(node)
