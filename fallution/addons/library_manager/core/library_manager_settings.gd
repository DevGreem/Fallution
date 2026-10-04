@tool
class_name LibraryManagerSettings
extends RefCounted

const PLUGIN_NAME := "LibraryManager"
const SETTING_STORAGE_PATH := PLUGIN_NAME + "/storage_path"
const SETTING_COMPONENTS_PATH := PLUGIN_NAME + "/components_path"
const DEFAULT_COMPONENTS_PATH := "res://components"


static func register() -> void:
	# The storage (library) path is personal and global to the editor, so it
	# lives in EditorSettings instead of ProjectSettings. This way it never ends
	# up inside project.godot (kept out of version control / shared with the
	# team) and you don't have to pick it again for every project.
	var editor_settings := _editor_settings()
	_migrate_storage_path(editor_settings)
	# Registered so it shows up in the Editor Settings UI (with a folder
	# picker) and can be edited at any time. It is still stored in the editor
	# config, not in project.godot.
	editor_settings.add_property_info({
		"name": SETTING_STORAGE_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_GLOBAL_DIR,
		"hint_string": "",
	})
	_register_project(
		SETTING_COMPONENTS_PATH, TYPE_STRING, PROPERTY_HINT_DIR, "", DEFAULT_COMPONENTS_PATH
	)


## Moves a storage path previously stored in ProjectSettings into EditorSettings
## (only once) so existing users keep their choice.
static func _migrate_storage_path(editor_settings: EditorSettings) -> void:
	if editor_settings.has_setting(SETTING_STORAGE_PATH):
		return
	var legacy: String = ProjectSettings.get_setting(SETTING_STORAGE_PATH, "")
	if legacy != "":
		editor_settings.set_setting(SETTING_STORAGE_PATH, legacy)
		editor_settings.mark_setting_changed(SETTING_STORAGE_PATH)
		ProjectSettings.set_setting(SETTING_STORAGE_PATH, null)
		ProjectSettings.save()
	else:
		editor_settings.set_setting(SETTING_STORAGE_PATH, "")


static func get_storage_path() -> String:
	var editor_settings := _editor_settings()
	if not editor_settings.has_setting(SETTING_STORAGE_PATH):
		return ""
	var path: String = editor_settings.get_setting(SETTING_STORAGE_PATH)
	return path


static func set_storage_path(path: String) -> void:
	var editor_settings := _editor_settings()
	editor_settings.set_setting(SETTING_STORAGE_PATH, path)
	editor_settings.mark_setting_changed(SETTING_STORAGE_PATH)


static func has_valid_storage_path() -> bool:
	var path := get_storage_path()
	return path != "" and DirAccess.dir_exists_absolute(path)


static func get_components_path() -> String:
	var path: String = ProjectSettings.get_setting(SETTING_COMPONENTS_PATH, DEFAULT_COMPONENTS_PATH)
	return path


static func get_absolute_components_path() -> String:
	return globalize(get_components_path())


static func globalize(path: String) -> String:
	if path.begins_with("res://"):
		return ProjectSettings.globalize_path(path)
	return path


static func _editor_settings() -> EditorSettings:
	return EditorInterface.get_editor_settings()


static func _register_project(
	setting_name: String,
	type: int,
	hint: int,
	hint_string: String,
	default_value: Variant
) -> void:
	if not ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_setting(setting_name, default_value)
	ProjectSettings.add_property_info({
		"name": setting_name, "type": type, "hint": hint, "hint_string": hint_string
	})
