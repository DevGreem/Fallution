@tool
class_name StoragePathSetup
extends FileDialog

## Emitted when the user confirms a folder selection.
signal path_selected(path: String)

const SCENE_PATH: String = "res://addons/library_manager/ui/storage_path_setup.tscn"


func _ready() -> void:
	# La apariencia base viene de la escena; aquí solo lo que depende
	# del entorno (carpeta inicial del sistema).
	current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	dir_selected.connect(_on_dir_selected)


func _on_dir_selected(path: String) -> void:
	path_selected.emit(path)
	hide()
