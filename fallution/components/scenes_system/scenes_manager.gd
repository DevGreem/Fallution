@tool
extends Node

signal scene_changed
signal close_requested

const NAME: String = "ScenesManager"

var _previous_scene: String = ""
var previous_scene: String:
	get: return _previous_scene
	set(value): return

var current_scene: String = "":
	set(value):
		
		if value == current_scene:
			return
		
		_previous_scene = current_scene
		current_scene = value

var _path_to_load: String
var path_to_load: String:
	get: return _path_to_load
	set(value): return

var _requested_time: float = -1.0
var requested_time: float:
	get: return _requested_time
	set(value): return

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if Engine.is_editor_hint():
		_setup_manager()
		return
	
	current_scene = get_tree().current_scene.scene_file_path

func close_game(make_transition_out: bool = true) -> void:
	
	if make_transition_out:
		await TransitionManager.transition_out()
	
	get_tree().quit()
	close_requested.emit()

func go_to_previous_scene(min_wait_time: float = -1.0) -> void:
	
	if previous_scene.is_empty():
		GameDebugger.debug_warning_string(
			NAME,
			"Trying to open a previos scene not available",
			true
		)
	
	load_scene(previous_scene, min_wait_time)

func reload_current_scene(min_wait_time: float = -1.0, make_transition: bool = true) -> void:
	
	if min_wait_time > 0.0:
		load_scene(get_tree().current_scene.scene_file_path, min_wait_time, make_transition, make_transition)
		return
		
	if make_transition:
		get_tree().paused = true
		await TransitionManager.transition_out()
	
	get_tree().reload_current_scene()
	
	if make_transition and min_wait_time <= 0.0:
		await TransitionManager.transition_in()
		get_tree().paused = false

func load_scene(path: String, min_wait_time: float = -1.0, transition_out: bool = true, transition_in: bool = true) -> void:
	
	if path.is_empty():
		GameDebugger.debug_error_string(
			NAME,
			"Path scene not provided",
			true
		)
		return
	
	if path == current_scene:
		return
	
	if min_wait_time <= 0.0:
		await _instant_load(path, transition_out, transition_in)
	else:
		await _load_with_screen(path, min_wait_time)

func change_to_packed_scene(scene: PackedScene) -> void:
	
	current_scene = scene.resource_path
	get_tree().change_scene_to_packed(scene)
	scene_changed.emit()
	
	get_tree().paused = false

func change_to_file(path: String) -> void:
	
	var scene: PackedScene = load(path)
	
	if not scene:
		GameDebugger.debug_error_string("ScenesManager", "File " + path + " not founded")
		return
	
	change_to_packed_scene(scene)

func _instant_load(path: String, transition_out: bool = true, transition_in: bool = true) -> void:
	
	
	if transition_out:
		get_tree().paused = true
		await TransitionManager.transition_out()
	
	change_to_file(path)
	
	if transition_in:
		await TransitionManager.transition_in()
	
	if transition_out:
		get_tree().paused = false

func finish_load(scene: PackedScene, pause_while_in_transition: bool = true) -> void:
	
	TransitionManager.display_transition()
	change_to_packed_scene(scene)
	path_to_load = ""
	requested_time = -1.0
	
	if pause_while_in_transition:
		get_tree().paused = true
	
	await TransitionManager.transition_in()
	get_tree().paused = false

func _load_with_screen(path: String, min_wait_time: float) -> void:
	
	var error: Error = ResourceLoader.load_threaded_request(path)
	
	if error != OK:
		GameDebugger.debug_error_string(
			NAME,
			"An error ocurred while loading a new scene",
			true
		)
		return
	
	_path_to_load = path
	_requested_time = min_wait_time
	
	get_tree().paused = true
	
	await TransitionManager.transition_out()
	
	_open_load_screen()
	TransitionManager.stash_transition()
	
	get_tree().paused = false

func _open_load_screen() -> void:
	
	GameDebugger.debug_log_string("ScenesManager", "Changing scene to load screen")
	
	var scene: String = ProjectSettings.get_setting(
		"scene_manager/load_screen"
	) as String
	
	if scene.is_empty():
		GameDebugger.debug_error_string(
			NAME,
			"Load Screen not found"
		)
		return
	
	GameDebugger.debug_log_string(NAME, "Opening load screen")
	
	var packed: PackedScene = load(scene)
	
	if not packed:
		GameDebugger.debug_error_string(NAME, "Load Screen not founded")
		return
	
	var instance: LoadingScreen = packed.instantiate()
	instance.load_verifier.await_time = requested_time
	
	get_tree().change_scene_to_node(instance)

func _setup_manager() -> void:
	
	const load_screen_path: String = "scene_manager/load_screen"
	
	if ProjectSettings.has_setting(load_screen_path):
		return
	
	ProjectSettings.set_setting(
		load_screen_path,
		""
	)
	ProjectSettings.set_initial_value(
		load_screen_path,
		""
	)
	
	ProjectSettings.set_as_basic(
		load_screen_path,
		true
	)
	
	ProjectSettings.add_property_info(
		{
			"name": load_screen_path,
			"type": TYPE_STRING,
			"hint": PropertyHint.PROPERTY_HINT_FILE,
			"hint_string": "*.tscn,*.scn"
		}
	)
	GameDebugger.debug_log_string("ScenesManager", "Added new project setting called scene_manager/load_screen")

func _get_setting(...parameters: Array) -> String:
	return "/".join(parameters)
