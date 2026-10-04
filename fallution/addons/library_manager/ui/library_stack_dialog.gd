@tool
class_name LibraryStackDialog
extends Window

## Emitted when the user saves a stack. `libraries` are library names (IDs).
signal saved(stack_name: String, libraries: Array[String])

const SCENE_PATH: String = "res://addons/library_manager/ui/library_stack_dialog.tscn"

var _taken_names: Array[String] = []

@onready var _name_edit: LineEdit = $Margin/VBox/NameRow/NameEdit
@onready var _tree: Tree = $Margin/VBox/Content/Tree
@onready var _empty_state: Label = $Margin/VBox/Content/EmptyState
@onready var _status: Label = $Margin/VBox/ButtonBar/StatusLabel
@onready var _save_button: Button = $Margin/VBox/ButtonBar/SaveButton
@onready var _error_label: Label = $Margin/VBox/ErrorLabel


static func open(
	parent: Node,
	all_libraries: Array[String],
	existing: LibraryStack,
	taken_names: Array[String]
) -> LibraryStackDialog:
	var scene := load(SCENE_PATH) as PackedScene
	if not scene:
		push_error("Library Manager: could not load stack dialog scene.")
		return null
	var dialog := scene.instantiate() as LibraryStackDialog
	parent.add_child(dialog)
	dialog._setup(all_libraries, existing, taken_names)
	dialog.popup_centered()
	return dialog


func _setup(all_libraries: Array[String], existing: LibraryStack, taken_names: Array[String]) -> void:
	_tree.set_column_title(0, "Include")
	_tree.set_column_title(1, "Library")
	_tree.set_column_expand(1, true)
	_apply_icons()
	_error_label.visible = false

	if existing:
		title = "Edit LibraryStack"
		_name_edit.text = existing.name
	else:
		title = "New LibraryStack"

	_taken_names = taken_names
	if not _name_edit.text_submitted.is_connected(_on_name_submitted):
		_name_edit.text_submitted.connect(_on_name_submitted)

	var checked: Array[String] = []
	if existing:
		checked = existing.libraries

	_tree.clear()
	var root: TreeItem = _tree.create_item()
	for lib_name: String in all_libraries:
		var item: TreeItem = _tree.create_item(root)
		item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		item.set_editable(0, true)
		item.set_text(1, lib_name)
		item.set_metadata(1, lib_name)
		item.set_checked(0, checked.has(lib_name))

	_update_empty_state()
	_update_status()
	_name_edit.grab_focus()


# ─── State ────────────────────────────────────────────────────

func _update_empty_state() -> void:
	if not _empty_state:
		return
	var root: TreeItem = _tree.get_root()
	_empty_state.visible = root == null or root.get_child_count() == 0


func _update_status() -> void:
	if not _status:
		return
	_status.text = "%d included" % _checked_count()


func _checked_count() -> int:
	var count: int = 0
	var root: TreeItem = _tree.get_root()
	if not root:
		return count
	var child: TreeItem = root.get_first_child()
	while child:
		if child.is_checked(0):
			count += 1
		child = child.get_next()
	return count


func _show_error(message: String) -> void:
	_error_label.text = message
	_error_label.visible = true


# ─── Icons ────────────────────────────────────────────────────

func _apply_icons() -> void:
	if not Engine.is_editor_hint():
		return
	var editor_theme: Theme = EditorInterface.get_editor_theme()
	_set_icon(_save_button, editor_theme, "Check")
	_set_icon($Margin/VBox/ButtonBar/CancelButton, editor_theme, "Close")


func _set_icon(button: Button, theme: Theme, icon_name: String) -> void:
	if button and theme and theme.has_icon(icon_name, "EditorIcons"):
		button.icon = theme.get_icon(icon_name, "EditorIcons")


# ─── Handlers ─────────────────────────────────────────────────

func _on_item_edited() -> void:
	_error_label.visible = false
	_update_status()


func _on_name_submitted(_text: String) -> void:
	_on_save_pressed()


func _on_save_pressed() -> void:
	var stack_name: String = _name_edit.text.strip_edges()
	if stack_name == "":
		_show_error("Please enter a name for the LibraryStack.")
		return
	if _taken_names.has(stack_name):
		_show_error("A LibraryStack named '%s' already exists." % stack_name)
		return

	var libs: Array[String] = []
	var root: TreeItem = _tree.get_root()
	if root:
		var child: TreeItem = root.get_first_child()
		while child:
			if child.is_checked(0):
				libs.append(String(child.get_metadata(1)))
			child = child.get_next()
	saved.emit(stack_name, libs)
	queue_free()


func _on_cancel_pressed() -> void:
	queue_free()


func _on_close_requested() -> void:
	queue_free()
