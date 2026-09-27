extends SpawnContainer2D

class_name GlobalSpawnContainer2D

@export var type: ContainerType.Enum

func _ready() -> void:
	SpawnManager2D.register_container(self)

func _exit_tree() -> void:
	SpawnManager2D.unregister_container(self.type)
