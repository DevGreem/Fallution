@tool
class_name LibraryContextMenu
extends EditorContextMenuPlugin

## Adds "Library Manager" entries to the FileSystem dock's right-click menu.
## The actual work is delegated to the host EditorPlugin (library_manager.gd),
## which owns the dialogs and the LibraryService.

const SAVE_ITEM := "Save Library to Storage..."
const DELETE_ITEM := "Delete Library from Project..."

var _host: Node


func _init(host: Node = null) -> void:
	_host = host


func _popup_menu(paths: PackedStringArray) -> void:
	if not _host or paths.size() != 1:
		return
	if not _is_project_folder(paths[0]):
		return
	add_context_menu_item(SAVE_ITEM, _on_save, _editor_icon("Save"))
	add_context_menu_item(DELETE_ITEM, _on_delete, _editor_icon("Remove"))


func _on_save(paths) -> void:
	if _host and paths.size() == 1:
		_host.request_save_library_from_context(String(paths[0]))


func _on_delete(paths) -> void:
	if _host and paths.size() == 1:
		_host.request_delete_library_from_context(String(paths[0]))


## The options only make sense for a single existing folder inside the project.
func _is_project_folder(path: String) -> bool:
	if path == "" or not path.begins_with("res://"):
		return false
	if path == "res://" or path == "res://.":
		return false
	return DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(path))


func _editor_icon(icon_name: String) -> Texture2D:
	if not Engine.is_editor_hint():
		return null
	var theme: Theme = EditorInterface.get_editor_theme()
	if theme and theme.has_icon(icon_name, "EditorIcons"):
		return theme.get_icon(icon_name, "EditorIcons")
	return null
