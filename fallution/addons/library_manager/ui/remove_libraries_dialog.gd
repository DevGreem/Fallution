@tool
class_name RemoveLibrariesDialog
extends Window

## Emitted when the user confirms a list of library names to remove.
signal remove_requested(lib_names: Array)

const SCENE_PATH: String = "res://addons/library_manager/ui/remove_libraries_dialog.tscn"

var _storage_path: String = ""
var _item_count: int = 0

@onready var _tree: Tree = $Margin/VBox/Content/Tree
@onready var _empty_state: Label = $Margin/VBox/Content/EmptyState
@onready var _storage_info: Label = $Margin/VBox/Header/StorageInfo
@onready var _search: LineEdit = $Margin/VBox/Toolbar/SearchEdit
@onready var _status: Label = $Margin/VBox/ButtonBar/StatusLabel
@onready var _remove_button: Button = $Margin/VBox/ButtonBar/RemoveButton


func _ready() -> void:
	_tree.set_column_title(0, "Library")
	_tree.set_column_expand(0, true)
	_apply_icons()
	_update_status()


func load_libraries(storage_path: String) -> void:
	_storage_path = storage_path
	_storage_info.text = "Storage: " + storage_path
	_storage_info.tooltip_text = storage_path
	_reload()


# ─── Data loading ─────────────────────────────────────────────

func _reload() -> void:
	if not _tree or not is_instance_valid(_tree):
		return
	_tree.clear()
	_item_count = 0
	var root: TreeItem = _tree.create_item()

	var dir := DirAccess.open(_storage_path)
	if not dir:
		push_warning("Library Manager: could not open storage folder: " + _storage_path)
		_update_empty_state()
		_update_status()
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with("."):
			var item := _tree.create_item(root)
			item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
			item.set_editable(0, true)
			item.set_text(0, entry)
			item.set_metadata(0, entry)
			item.set_checked(0, false)
			item.set_tooltip_text(0, entry)
			_item_count += 1
		entry = dir.get_next()
	dir.list_dir_end()

	_apply_filter()
	_update_empty_state()
	_update_status()


# ─── Filtering & status ───────────────────────────────────────

func _on_search_text_changed(_new_text: String) -> void:
	_apply_filter()
	_update_empty_state()


func _apply_filter() -> void:
	var query: String = _search.text.strip_edges().to_lower()
	var root: TreeItem = _tree.get_root()
	if not root:
		return
	var child: TreeItem = root.get_first_child()
	while child:
		child.set_visible(query == "" or String(child.get_metadata(0)).to_lower().contains(query))
		child = child.get_next()


func _visible_item_count() -> int:
	var count: int = 0
	var root: TreeItem = _tree.get_root()
	if not root:
		return 0
	var child: TreeItem = root.get_first_child()
	while child:
		if child.is_visible():
			count += 1
		child = child.get_next()
	return count


func _update_empty_state() -> void:
	if not _empty_state:
		return
	if _item_count == 0:
		_empty_state.text = "No libraries found in the storage folder."
		_empty_state.visible = true
	elif _visible_item_count() == 0:
		_empty_state.text = "No libraries match this filter."
		_empty_state.visible = true
	else:
		_empty_state.visible = false


func _update_status() -> void:
	if not _status:
		return
	var selected: Array = get_selected_libraries()
	_status.text = "%d of %d selected" % [selected.size(), _item_count]
	_remove_button.disabled = selected.is_empty()


func _apply_icons() -> void:
	if not Engine.is_editor_hint():
		return
	var editor_theme: Theme = EditorInterface.get_editor_theme()
	_set_icon($Margin/VBox/Toolbar/RefreshButton, editor_theme, "Reload")
	_set_icon(_remove_button, editor_theme, "Delete")
	_set_icon($Margin/VBox/ButtonBar/CancelButton, editor_theme, "Close")
	_set_icon($Margin/VBox/ButtonBar/SelectAllButton, editor_theme, "Check")
	_set_icon($Margin/VBox/ButtonBar/DeselectAllButton, editor_theme, "Close")


func _set_icon(button: Button, theme: Theme, icon_name: String) -> void:
	if button and theme and theme.has_icon(icon_name, "EditorIcons"):
		button.icon = theme.get_icon(icon_name, "EditorIcons")


# ─── Button handlers ──────────────────────────────────────────

func _on_refresh_pressed() -> void:
	_reload()


func _on_tree_item_edited() -> void:
	_update_status()


func _on_select_all_pressed() -> void:
	var root := _tree.get_root()
	if not root:
		return
	var child := root.get_first_child()
	while child:
		if child.is_visible():
			child.set_checked(0, true)
		child = child.get_next()
	_update_status()


func _on_deselect_all_pressed() -> void:
	var root := _tree.get_root()
	if not root:
		return
	var child := root.get_first_child()
	while child:
		child.set_checked(0, false)
		child = child.get_next()
	_update_status()


func _on_cancel_pressed() -> void:
	hide()


func _on_close_requested() -> void:
	hide()


func _on_remove_pressed() -> void:
	var selected := get_selected_libraries()
	if selected.is_empty():
		push_warning("Library Manager: no libraries selected for removal.")
		return
	remove_requested.emit(selected)


# ─── Queries ──────────────────────────────────────────────────

func get_selected_libraries() -> Array:
	var result: Array = []
	var root := _tree.get_root()
	if not root:
		return result
	var child := root.get_first_child()
	while child:
		if child.is_checked(0):
			result.append(child.get_metadata(0))
		child = child.get_next()
	return result
