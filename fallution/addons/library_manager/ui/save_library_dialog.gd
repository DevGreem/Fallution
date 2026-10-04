@tool
class_name SaveLibraryDialog
extends FileDialog

## Emitted when the user confirms a folder to save as library.
signal library_selected(source_path: String)

const SCENE_PATH: String = "res://addons/library_manager/ui/save_library_dialog.tscn"


func _ready() -> void:
	# Solo carpetas, solo dentro del proyecto, sin diálogo nativo
	# (los diálogos nativos no entienden res://).
	file_mode = FileDialog.FILE_MODE_OPEN_DIR
	access = FileDialog.ACCESS_RESOURCES
	use_native_dialog = false
	current_dir = "res://"
	dir_selected.connect(_on_dir_selected)


func _on_dir_selected(path: String) -> void:
	library_selected.emit(path)
	hide()
