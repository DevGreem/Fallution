extends Area2D

class_name LeafsSpawner

@export var collision: CollisionShape2D
@export var spawn_time: float
@export var spawn_cantity_range: Vector2i:
	set(value):
		spawn_cantity_range = value.max(Vector2(0, 0))

@export var max_spawn_leafs: int:
	set(value):
		max_spawn_leafs = max(value, 0)

const LEAFS_DATABASE: Registry = preload("uid://b5ontlvcp1fft")

var current_spawn_time: float

func _ready() -> void:
	current_spawn_time = spawn_time

func _process(delta: float) -> void:
	
	var leafs: int = get_total_leafs()
	
	if leafs >= max_spawn_leafs:
		return
	
	if current_spawn_time > 0:
		current_spawn_time -= delta
		return
	
	current_spawn_time = spawn_time
	
	var cant_to_spawn: int = randi_range(spawn_cantity_range.x, spawn_cantity_range.y)
	
	cant_to_spawn = min(max_spawn_leafs - leafs, cant_to_spawn)
	
	var IDS := LEAFS_DATABASE.get_all_string_ids()
	for i: int in range(cant_to_spawn):
		
		var leaf: LeafInfo = LEAFS_DATABASE.load_entry(IDS.pick_random() as StringName)
		
		spawn_leaf(leaf)
	
func get_total_leafs() -> int:
	return get_tree().get_node_count_in_group("leafs")

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
	node.rotation_degrees = randi_range(-180, 180)
	
	var container := SpawnManager2D.get_container(ContainerType.Enum.ENTITIES)
	container.add_child(node)
