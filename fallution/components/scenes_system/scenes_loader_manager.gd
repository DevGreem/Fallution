extends Node

var _loading_path: String = ""
var load_screen_ready: bool = false

@export var default_wait_time: float = -1.0
var await_time: float = -1.0

#func _ready() -> void:
	#return
	#process_mode = Node.PROCESS_MODE_ALWAYS
	#
	#if not ScenesManager.load_requested.is_connected(_on_load_requested):
		#ScenesManager.load_requested.connect(_on_load_requested)

func _process(delta: float) -> void:
	
	if not _loading_path:
		return
	
	if not load_screen_ready and await_time > 0.0:
		return
	
	if await_time > 0.0:
		await_time -= delta
		return
	
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(_loading_path)
	
	if status == ResourceLoader.THREAD_LOAD_FAILED:
		cancel_load()
		GameDebugger.debug_error_string("ScenesLoaderManager", "Scene thread load failed\nScene: " + _loading_path)
		return
	
	if status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		cancel_load()
		GameDebugger.debug_error_string("ScenesLoaderManager", "Invalid scene\nPath: " + _loading_path)
		return
	
	if status != ResourceLoader.THREAD_LOAD_LOADED:
		return
	
	var scene: PackedScene = ResourceLoader.load_threaded_get(_loading_path)
	finish_load(scene)

func finish_load(scene: PackedScene) -> void:
	_loading_path = ""
	load_screen_ready = false
	await_time = default_wait_time
	ScenesManager.change_to_packed_scene(scene)

func cancel_load() -> void:
	_loading_path = ""
	ScenesManager.go_to_previous_scene()

func load_screen_loaded() -> void:
	GameDebugger.debug_log_string("ScenesLoaderManager", "Loading screen is ready")
	load_screen_ready = true

func _on_load_requested(path: String, time: float = -1.0) -> void:
	_loading_path = path
	
	if time > 0.0:
		await_time = time
	else:
		await_time = default_wait_time
