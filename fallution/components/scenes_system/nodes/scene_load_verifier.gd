extends Node

class_name SceneLoadVerifier

@export var await_time: float = -1.0

func _process(delta: float) -> void:
	
	if await_time > 0.0:
		await_time -= delta
		return
	
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(ScenesManager.path_to_load)
	
	if status == ResourceLoader.THREAD_LOAD_FAILED:
		ScenesManager.go_to_previous_scene()
		GameDebugger.debug_error(SceneLoadVerifier, "Scene thread load failed\nScene: " + ScenesManager.path_to_load)
		return
	
	if status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		ScenesManager.go_to_previous_scene()
		GameDebugger.debug_error(SceneLoadVerifier, "Invalid scene\nPath: " + ScenesManager.path_to_load)
		return
	
	if status != ResourceLoader.THREAD_LOAD_LOADED:
		return
	
	var scene: PackedScene = ResourceLoader.load_threaded_get(ScenesManager.path_to_load)
	ScenesManager.finish_load(scene)
