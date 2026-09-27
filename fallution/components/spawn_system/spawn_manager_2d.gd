extends Node

signal container_registered
signal container_unregistered

var containers: Dictionary[ContainerType.Enum, GlobalSpawnContainer2D] = {}

func register_container(container: GlobalSpawnContainer2D) -> void:
	containers[container.type] = container
	container_registered.emit()

func unregister_container(type: ContainerType.Enum) -> bool:
	
	if not containers.has(type):
		return false
	
	containers.erase(type)
	container_unregistered.emit()
	return true

func get_container(type: ContainerType.Enum) -> GlobalSpawnContainer2D:
	var container: GlobalSpawnContainer2D =  containers.get(type)
	
	if not container:
		GameDebugger.debug_error_string(
			"SpawnManager2D",
			"You are trying to get a container of type "
			+ str(ContainerType.as_string(type))
			+ " that don't exists"
		)
	
	return container
