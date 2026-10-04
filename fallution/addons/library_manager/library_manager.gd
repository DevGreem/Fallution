@tool
extends EditorPlugin

var _ui_root: Node
var _service: LibraryService

var _dialog: LibraryDialog
var _setup: StoragePathSetup
var _save_dialog: SaveLibraryDialog
var _remove_dialog: RemoveLibrariesDialog
var _context_menu: LibraryContextMenu

# Pending state while a confirmation dialog is open.
var _pending_add: Array = []
var _pending_gh: Array = []
var _pending_save_source: String = ""
var _pending_push_libs: Array = []


func _enter_tree() -> void:
	LibraryManagerSettings.register()
	add_tool_menu_item("Manage Libraries...", _show_library_dialog)
	add_tool_menu_item("Save Library...", _show_save_library_dialog)
	add_tool_menu_item("Remove Libraries...", _show_remove_libraries_dialog)

	_context_menu = LibraryContextMenu.new(self)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, _context_menu)

	_ui_root = Node.new()
	_ui_root.name = "UI"
	add_child(_ui_root)

	_service = LibraryService.new()
	_service.name = "Service"
	add_child(_service)
	_service.github_progress.connect(_on_github_progress)
	_service.changed.connect(_on_filesystem_changed)
	_service.apply_finished.connect(_on_apply_finished)
	_service.update_finished.connect(_on_update_finished)
	_service.push_finished.connect(_on_push_finished)
	_service.remove_finished.connect(_on_remove_finished)
	_service.save_finished.connect(_on_save_finished)

	_check_and_prompt_storage_path()


func _exit_tree() -> void:
	remove_tool_menu_item("Manage Libraries...")
	remove_tool_menu_item("Save Library...")
	remove_tool_menu_item("Remove Libraries...")
	if _context_menu:
		remove_context_menu_plugin(_context_menu)
		_context_menu = null
	_dialog = null
	_setup = null
	_save_dialog = null
	_remove_dialog = null
	if _ui_root and is_instance_valid(_ui_root):
		_ui_root.queue_free()
		_ui_root = null
	if _service and is_instance_valid(_service):
		_service.queue_free()
		_service = null


# ─── Storage path ─────────────────────────────────────────────

func _check_and_prompt_storage_path() -> void:
	if not LibraryManagerSettings.has_valid_storage_path():
		_show_storage_setup()


func _show_storage_setup() -> void:
	_dismiss(_setup)
	_setup = _open_window(StoragePathSetup.SCENE_PATH) as StoragePathSetup
	if not _setup:
		return
	_setup.path_selected.connect(_on_storage_path_selected)
	_setup.canceled.connect(_on_storage_path_canceled)
	_setup.popup_centered()


func _on_storage_path_selected(path: String) -> void:
	LibraryManagerSettings.set_storage_path(path)
	print("Library Manager: storage path set to: ", path)
	_dismiss(_setup)
	_setup = null


func _on_storage_path_canceled() -> void:
	push_warning("Library Manager: no storage folder was selected.")
	_dismiss(_setup)
	_setup = null


# ─── Manage libraries ─────────────────────────────────────────

func _show_library_dialog() -> void:
	if not LibraryManagerSettings.has_valid_storage_path():
		push_warning("Library Manager: please choose the storage folder first.")
		_show_storage_setup()
		return

	_dismiss(_dialog)
	_dialog = _open_window(LibraryDialog.SCENE_PATH) as LibraryDialog
	if not _dialog:
		return
	_dialog.apply_requested.connect(_on_apply_requested)
	_dialog.update_requested.connect(_on_update_requested)
	_dialog.push_requested.connect(_on_push_requested)
	_dialog.load_libraries(
		LibraryManagerSettings.get_storage_path(),
		LibraryManagerSettings.get_absolute_components_path()
	)
	_dialog.popup_centered()


# ─── Apply ────────────────────────────────────────────────────

func _on_apply_requested(libs_to_add: Array, libs_to_remove: Array, github_deps: Array) -> void:
	if libs_to_remove.is_empty():
		_service.apply(libs_to_add, libs_to_remove, github_deps)
		return

	if _dialog and is_instance_valid(_dialog):
		_dialog.hide()

	_pending_add = libs_to_add
	_pending_gh = github_deps

	var confirm := LibraryConfirmDialog.open(
		_ui_root,
		"Confirm Deletion",
		(
			"The following libraries will be removed from the project:\n\n  • " +
			"\n  • ".join(libs_to_remove) +
			"\n\nThis action cannot be undone."
		),
		"Delete",
		"Cancel",
		true
	)
	confirm.confirmed.connect(_on_delete_confirmed.bind(libs_to_remove))
	confirm.canceled.connect(_on_delete_canceled)


func _on_delete_canceled() -> void:
	_pending_add = []
	_pending_gh = []
	if _dialog and is_instance_valid(_dialog):
		_dialog.popup_centered()


func _on_delete_confirmed(libs_to_remove: Array) -> void:
	var add := _pending_add
	var gh := _pending_gh
	_pending_add = []
	_pending_gh = []
	_service.apply(add, libs_to_remove, gh)


func _on_apply_finished() -> void:
	if _dialog and is_instance_valid(_dialog):
		_dialog.hide()


# ─── Update from storage ──────────────────────────────────────

func _on_update_requested(libs_to_update: Array) -> void:
	_service.update_from_storage(libs_to_update)


func _on_update_finished() -> void:
	if _dialog and is_instance_valid(_dialog):
		_dialog.load_libraries(
			LibraryManagerSettings.get_storage_path(),
			LibraryManagerSettings.get_absolute_components_path()
		)


# ─── Push to storage ──────────────────────────────────────────

func _on_push_requested(libs_to_push: Array) -> void:
	if libs_to_push.is_empty():
		return

	_pending_push_libs = libs_to_push

	if _dialog and is_instance_valid(_dialog):
		_dialog.hide()

	var confirm := LibraryConfirmDialog.open(
		_ui_root,
		"Confirm Push to Storage",
		(
			"The storage versions of the following libraries will be overwritten:\n\n  • " +
			"\n  • ".join(libs_to_push) +
			"\n\nThis cannot be undone."
		),
		"Push",
		"Cancel",
		true
	)
	confirm.confirmed.connect(_on_push_confirmed)
	confirm.canceled.connect(_on_push_canceled)


func _on_push_confirmed() -> void:
	var libs := _pending_push_libs
	_pending_push_libs = []
	_service.push_to_storage(libs)


func _on_push_canceled() -> void:
	_pending_push_libs = []
	if _dialog and is_instance_valid(_dialog):
		_dialog.popup_centered()


func _on_push_finished() -> void:
	if _dialog and is_instance_valid(_dialog):
		_dialog.hide()


# ─── Remove libraries ─────────────────────────────────────────

func _show_remove_libraries_dialog() -> void:
	if not LibraryManagerSettings.has_valid_storage_path():
		push_warning("Library Manager: please choose the storage folder first.")
		_show_storage_setup()
		return

	var storage_path := LibraryManagerSettings.get_storage_path()
	_dismiss(_remove_dialog)
	_remove_dialog = _open_window(RemoveLibrariesDialog.SCENE_PATH) as RemoveLibrariesDialog
	if not _remove_dialog:
		return
	_remove_dialog.remove_requested.connect(_on_remove_libraries_requested)
	_remove_dialog.load_libraries(storage_path)
	_remove_dialog.popup_centered()


func _on_remove_libraries_requested(lib_names: Array) -> void:
	if lib_names.is_empty():
		return

	if _remove_dialog and is_instance_valid(_remove_dialog):
		_remove_dialog.hide()

	var confirm := LibraryConfirmDialog.open(
		_ui_root,
		"Confirm Deletion",
		(
			"The following libraries will be removed from the storage folder:\n\n  • " +
			"\n  • ".join(lib_names) +
			"\n\nThis action cannot be undone."
		),
		"Delete",
		"Cancel",
		true
	)
	confirm.confirmed.connect(_on_remove_libraries_confirmed.bind(lib_names))
	confirm.canceled.connect(_on_remove_libraries_canceled)


func _on_remove_libraries_confirmed(lib_names: Array) -> void:
	_service.remove_libraries(lib_names)


func _on_remove_libraries_canceled() -> void:
	if _remove_dialog and is_instance_valid(_remove_dialog):
		_remove_dialog.popup_centered()


func _on_remove_finished() -> void:
	if _remove_dialog and is_instance_valid(_remove_dialog):
		_remove_dialog.hide()


# ─── FileSystem dock context menu ─────────────────────────────

## Called from the right-click menu to save a project folder to the storage.
func request_save_library_from_context(source_path: String) -> void:
	if not LibraryManagerSettings.has_valid_storage_path():
		push_warning("Library Manager: please choose the storage folder first.")
		_show_storage_setup()
		return
	_on_save_library_selected(source_path)


## Called from the right-click menu. Deletes the selected library from the
## project, including every library that depends on it (recursively), after
## listing them in a confirmation dialog.
func request_delete_library_from_context(source_path: String) -> void:
	var source := _normalize_res_path(source_path)
	if source == "res://" or source == "res://.":
		push_warning("Library Manager: cannot delete the project root.")
		return

	var components := LibraryManagerSettings.get_components_path()
	var lib_name := source.get_file()
	var target_path := source

	# If a subfolder of the components root was clicked, delete the whole
	# library folder instead of just the clicked subfolder.
	if components != "" and source.begins_with(components + "/"):
		lib_name = source.substr(components.length() + 1).get_slice("/", 0)
		target_path = components.path_join(lib_name)

	if lib_name == "":
		push_warning("Library Manager: invalid folder selection.")
		return

	var components_abs := LibraryManagerSettings.get_absolute_components_path()
	var dependents := _service.find_project_dependents(lib_name)
	var folders: Array[String] = [LibraryManagerSettings.globalize(target_path)]
	for dep: String in dependents:
		folders.append(components_abs.path_join(dep))

	var confirm := LibraryConfirmDialog.open(
		_ui_root,
		"Delete Library from Project",
		_build_project_delete_message(lib_name, dependents),
		"Delete",
		"Cancel",
		true
	)
	confirm.confirmed.connect(_on_project_delete_confirmed.bind(folders))


func _build_project_delete_message(lib_name: String, dependents: Array) -> String:
	if dependents.is_empty():
		return (
			"Remove the library '%s' from the project?\n\n" % lib_name +
			"No other library depends on it, so only this library will be deleted."
			+ "\n\nThis action cannot be undone."
		)
	return (
		"Remove the library '%s' from the project?\n\n" % lib_name +
		"The following libraries depend on '%s' (directly or indirectly) " % lib_name +
		"and will be removed as well:\n\n  • " +
		"\n  • ".join(dependents) +
		"\n\nThis action cannot be undone."
	)


func _on_project_delete_confirmed(folders: Array) -> void:
	_service.remove_project_folders(folders)


# ─── Save library ─────────────────────────────────────────────

func _show_save_library_dialog() -> void:
	if not LibraryManagerSettings.has_valid_storage_path():
		push_warning("Library Manager: please choose the storage folder first.")
		_show_storage_setup()
		return

	_dismiss(_save_dialog)
	_save_dialog = _open_window(SaveLibraryDialog.SCENE_PATH) as SaveLibraryDialog
	if not _save_dialog:
		return
	_save_dialog.library_selected.connect(_on_save_library_selected)
	_save_dialog.popup_centered()


func _on_save_library_selected(source_path: String) -> void:
	var normalized := _normalize_res_path(source_path)

	if normalized == "res://" or normalized == "res://.":
		push_warning("Library Manager: cannot save the project root as a library.")
		return

	var lib_name := normalized.get_file()
	if lib_name == "":
		push_warning("Library Manager: invalid folder selection.")
		return

	var storage_path := LibraryManagerSettings.get_storage_path()
	if DirAccess.dir_exists_absolute(storage_path.path_join(lib_name)):
		_pending_save_source = normalized
		_show_save_overwrite_confirmation(lib_name)
		return

	_service.save_library(normalized, lib_name)


func _show_save_overwrite_confirmation(lib_name: String) -> void:
	if _save_dialog and is_instance_valid(_save_dialog):
		_save_dialog.hide()

	var confirm := LibraryConfirmDialog.open(
		_ui_root,
		"Overwrite Library",
		(
			"A library named '%s' already exists in the storage folder.\n\n" % lib_name +
			"Do you want to overwrite it?\n\nThe existing folder will be deleted."
		),
		"Overwrite",
		"Cancel",
		true
	)
	confirm.confirmed.connect(_on_save_overwrite_confirmed.bind(lib_name))
	confirm.canceled.connect(_on_save_overwrite_canceled)


func _on_save_overwrite_confirmed(lib_name: String) -> void:
	var source := _pending_save_source
	_pending_save_source = ""
	_service.save_library(source, lib_name)


func _on_save_overwrite_canceled() -> void:
	_pending_save_source = ""
	if _save_dialog and is_instance_valid(_save_dialog):
		_save_dialog.popup_centered()


func _on_save_finished(success: bool, message: String) -> void:
	if not success:
		push_error("Library Manager: " + message)
		return
	if _save_dialog and is_instance_valid(_save_dialog):
		_save_dialog.hide()


# ─── Helpers ──────────────────────────────────────────────────

func _open_window(scene_path: String) -> Window:
	var scene := load(scene_path) as PackedScene
	if not scene:
		push_error("Library Manager: could not load scene: " + scene_path)
		return null
	var window := scene.instantiate() as Window
	if not window:
		push_error("Library Manager: scene is not a Window: " + scene_path)
		return null
	_ui_root.add_child(window)
	return window


func _dismiss(window: Window) -> void:
	if window and is_instance_valid(window):
		window.queue_free()


## Trims whitespace and trailing slashes from a res:// folder path.
func _normalize_res_path(path: String) -> String:
	var normalized := path.strip_edges()
	while normalized.ends_with("/") and normalized.length() > "res://".length():
		normalized = normalized.substr(0, normalized.length() - 1)
	return normalized


func _on_github_progress(url: String, message: String) -> void:
	print("Library Manager: [%s] %s" % [url, message])


func _on_filesystem_changed() -> void:
	EditorInterface.get_resource_filesystem().scan()
