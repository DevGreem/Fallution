@tool
extends Node

class_name ChangeSceneNode

enum Method {
	CHANGE,
	REPEAT,
	QUIT
}

@export var method: Method = Method.CHANGE:
	set(value):
		method = value
		notify_property_list_changed()

@export_file("*.tscn") var scene_file: String
@export var min_wait_time: float = -1.0

func change() -> void:
	if Engine.is_editor_hint():
		return
	
	if method == Method.QUIT:
		ScenesManager.close_game()
		return
	
	if method == Method.REPEAT:
		ScenesManager.reload_current_scene(min_wait_time)
		return
	
	GameDebugger.debug_log(ChangeSceneNode, "Trying to load scene " + scene_file)
	ScenesManager.load_scene(scene_file, min_wait_time, true, true)

func _validate_property(property: Dictionary) -> void:
	
	if property.name == "scene_file":
		if method != Method.CHANGE:
			property.usage = PROPERTY_USAGE_NO_EDITOR
