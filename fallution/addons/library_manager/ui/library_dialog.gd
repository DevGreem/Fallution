@tool
class_name LibraryDialog
extends Window

## `libs_to_add`: checked libraries (will be copied/updated).
## `libs_to_remove`: libraries present in the project that got unchecked.
## `github_deps`: GitHub URLs required by the selected libraries.
signal apply_requested(libs_to_add: Array, libs_to_remove: Array, github_deps: Array)
signal update_requested(libs_to_update: Array)
signal push_requested(libs_to_push: Array)

const SCENE_PATH: String = "res://addons/library_manager/ui/library_dialog.tscn"

var _storage_path: String = ""
var _components_path: String = ""
var _libraries: Array[LibraryData] = []
var _initially_present: Array[String] = []
var _stacks: Array[LibraryStack] = []

@onready var _tree: Tree = $Margin/VBox/Tabs/Libraries/Content/Tree
@onready var _empty_state: Label = $Margin/VBox/Tabs/Libraries/Content/EmptyState
@onready var _storage_info: Label = $Margin/VBox/Header/StorageInfo
@onready var _open_storage_button: Button = $Margin/VBox/Header/TitleRow/OpenStorageButton
@onready var _search: LineEdit = $Margin/VBox/Tabs/Libraries/Toolbar/SearchEdit
@onready var _refresh_button: Button = $Margin/VBox/Tabs/Libraries/Toolbar/RefreshButton
@onready var _update_button: Button = $Margin/VBox/SyncBar/UpdateFromStorageButton
@onready var _push_button: Button = $Margin/VBox/SyncBar/PushToStorageButton
@onready var _status: Label = $Margin/VBox/ButtonBar/StatusLabel
@onready var _apply_button: Button = $Margin/VBox/ButtonBar/ApplyButton

@onready var _tabs: TabContainer = $Margin/VBox/Tabs
@onready var _stack_tree: Tree = $Margin/VBox/Tabs/LibraryStacks/StackContent/StackTree
@onready var _stack_empty_state: Label = $Margin/VBox/Tabs/LibraryStacks/StackContent/StackEmptyState
@onready var _new_stack_button: Button = $Margin/VBox/Tabs/LibraryStacks/StackToolbar/NewStackButton
@onready var _edit_stack_button: Button = $Margin/VBox/Tabs/LibraryStacks/StackToolbar/EditStackButton
@onready var _delete_stack_button: Button = $Margin/VBox/Tabs/LibraryStacks/StackToolbar/DeleteStackButton


func _ready() -> void:
	_tree.set_column_title(0, "Library")
	_tree.set_column_title(1, "Dependencies")
	_tree.set_column_expand(0, true)
	_tree.set_column_expand(1, true)
	_tree.set_column_custom_minimum_width(0, 200)
	_tree.set_column_custom_minimum_width(1, 220)
	_stack_tree.set_column_title(0, "LibraryStack")
	_stack_tree.set_column_title(1, "Libraries")
	_stack_tree.set_column_expand(0, true)
	_stack_tree.set_column_expand(1, true)
	_apply_icons()
	_update_stack_buttons()
	_update_status()


func load_libraries(storage_path: String, components_path: String = "") -> void:
	_storage_path = storage_path
	_components_path = components_path
	_storage_info.text = "Storage: " + storage_path
	_storage_info.tooltip_text = storage_path
	_open_storage_button.disabled = not DirAccess.dir_exists_absolute(storage_path)
	_reload()


# ─── Data loading ─────────────────────────────────────────────

func _reload() -> void:
	if not _tree or not is_instance_valid(_tree):
		return
	_tree.clear()
	_initially_present.clear()
	var root: TreeItem = _tree.create_item()
	_libraries = LibraryScanner.scan(_storage_path)
	for lib: LibraryData in _libraries:
		_add_item(root, lib)
	_preselect_existing()
	_apply_filter()
	_update_empty_state()
	_update_status()
	_load_stacks()
	_refresh_stack_tree()


func _add_item(root: TreeItem, lib: LibraryData) -> void:
	var item: TreeItem = _tree.create_item(root)
	item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	item.set_editable(0, true)
	item.set_text(0, lib.name)
	item.set_metadata(0, lib.name)
	item.set_checked(0, false)

	if not lib.has_dependencies_file:
		item.set_text(1, "(no dependencies.txt)")
		item.set_custom_color(1, Color(0.85, 0.65, 0.35))
		item.set_tooltip_text(1, "This library has no dependencies.txt file.")
	else:
		var parts: Array[String] = lib.dependencies_display()
		item.set_text(1, ", ".join(parts) if parts.size() > 0 else "—")
		if parts.size() > 0:
			item.set_tooltip_text(1, ", ".join(parts))

	item.set_metadata(1, lib.dependencies)

	if _library_exists_in_project(lib.name):
		item.set_custom_color(0, Color(0.65, 0.85, 0.65))
		item.set_tooltip_text(0, "%s\nAlready present in the project" % lib.name)
	else:
		item.set_tooltip_text(0, lib.name)


func _library_exists_in_project(lib_name: String) -> bool:
	if _components_path == "":
		return false
	return DirAccess.dir_exists_absolute(_components_path.path_join(lib_name))


func _preselect_existing() -> void:
	if _components_path == "":
		return
	for lib: LibraryData in _libraries:
		if _library_exists_in_project(lib.name):
			_initially_present.append(lib.name)
			var item: TreeItem = _find_item_by_name(lib.name)
			if item and not item.is_checked(0):
				_check_dependencies_recursive(lib.name)


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
		child.set_visible(query == "" or _matches_query(child, query))
		child = child.get_next()


func _matches_query(item: TreeItem, query: String) -> bool:
	if String(item.get_metadata(0)).to_lower().contains(query):
		return true
	for dep: Variant in item.get_metadata(1):
		if String(dep).to_lower().contains(query):
			return true
	return false


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
	if _libraries.is_empty():
		_empty_state.text = (
			"No libraries found in the storage folder.\n"
			+ "Use “Save Library…” to add one, or check the storage path."
		)
		_empty_state.visible = true
	elif _visible_item_count() == 0:
		_empty_state.text = "No libraries match this filter."
		_empty_state.visible = true
	else:
		_empty_state.visible = false


func _update_status() -> void:
	if not _status:
		return
	var selected: Array[String] = get_selected_libraries()
	var to_remove: Array[String] = get_libraries_to_remove()
	_status.text = "%d of %d selected" % [selected.size(), _libraries.size()]
	_apply_button.disabled = selected.is_empty() and to_remove.is_empty()
	var existing: Array[String] = _filter_existing_in_project(selected)
	_update_button.disabled = existing.is_empty()
	_push_button.disabled = existing.is_empty()


func _apply_icons() -> void:
	if not Engine.is_editor_hint():
		return
	var editor_theme: Theme = EditorInterface.get_editor_theme()
	_set_icon(_refresh_button, editor_theme, "Reload")
	_set_icon(_open_storage_button, editor_theme, "Folder")
	_set_icon(_update_button, editor_theme, "ArrowDown")
	_set_icon(_push_button, editor_theme, "ArrowUp")
	_set_icon(_apply_button, editor_theme, "Check")
	_set_icon($Margin/VBox/ButtonBar/CancelButton, editor_theme, "Close")
	_set_icon($Margin/VBox/ButtonBar/SelectAllButton, editor_theme, "Check")
	_set_icon($Margin/VBox/ButtonBar/DeselectAllButton, editor_theme, "Close")
	_set_icon(_new_stack_button, editor_theme, "Add")
	_set_icon(_edit_stack_button, editor_theme, "Edit")
	_set_icon(_delete_stack_button, editor_theme, "Remove")


func _set_icon(button: Button, theme: Theme, icon_name: String) -> void:
	if button and theme and theme.has_icon(icon_name, "EditorIcons"):
		button.icon = theme.get_icon(icon_name, "EditorIcons")


# ─── LibraryStacks ────────────────────────────────────────────

func _load_stacks() -> void:
	_stacks = LibraryStackStore.load_stacks(_storage_path)


func _refresh_stack_tree() -> void:
	if not _stack_tree or not is_instance_valid(_stack_tree):
		return
	_stack_tree.clear()
	var root: TreeItem = _stack_tree.create_item()
	for stack: LibraryStack in _stacks:
		var stack_item: TreeItem = _stack_tree.create_item(root)
		stack_item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		stack_item.set_editable(0, true)
		stack_item.set_text(0, stack.name)
		stack_item.set_metadata(0, stack.name)
		stack_item.set_text(1, "%d" % stack.libraries.size())
		stack_item.set_tooltip_text(0, stack.name)
		for lib_name: String in stack.libraries:
			var lib_item: TreeItem = _stack_tree.create_item(stack_item)
			lib_item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
			lib_item.set_editable(0, true)
			lib_item.set_text(0, lib_name)
			lib_item.set_metadata(0, stack.name)
			lib_item.set_metadata(1, lib_name)
			if _find_item_by_name(lib_name):
				lib_item.set_tooltip_text(0, lib_name)
			else:
				lib_item.set_custom_color(0, Color(0.85, 0.65, 0.35))
				lib_item.set_tooltip_text(0, lib_name + " (not found in storage)")
	_update_stack_check_states()
	_update_stack_empty_state()
	_update_stack_buttons()


## Syncs every LibraryStack checkbox with the current Libraries tab selection:
## checked when all its libraries are selected, indeterminate when only some
## are, unchecked when none are.
func _update_stack_check_states() -> void:
	if not _stack_tree or not is_instance_valid(_stack_tree):
		return
	var root: TreeItem = _stack_tree.get_root()
	if not root:
		return
	var stack_item: TreeItem = root.get_first_child()
	while stack_item:
		var stack := _stack_by_name(String(stack_item.get_metadata(0)))
		if stack:
			_update_stack_item_state(stack_item, stack)
		stack_item = stack_item.get_next()


func _update_stack_item_state(stack_item: TreeItem, stack: LibraryStack) -> void:
	var total: int = stack.libraries.size()
	var checked: int = 0
	for lib_name: String in stack.libraries:
		var lib_item: TreeItem = _find_item_by_name(lib_name)
		if lib_item and lib_item.is_checked(0):
			checked += 1

	if total == 0 or checked == 0:
		stack_item.set_checked(0, false)
		stack_item.set_indeterminate(0, false)
	elif checked == total:
		stack_item.set_checked(0, true)
		stack_item.set_indeterminate(0, false)
	else:
		stack_item.set_checked(0, false)
		stack_item.set_indeterminate(0, true)

	var child: TreeItem = stack_item.get_first_child()
	while child:
		var lib_name := String(child.get_metadata(1))
		var lib_item: TreeItem = _find_item_by_name(lib_name)
		child.set_checked(0, lib_item != null and lib_item.is_checked(0))
		child.set_indeterminate(0, false)
		child = child.get_next()


func _update_stack_empty_state() -> void:
	if not _stack_empty_state:
		return
	_stack_empty_state.visible = _stacks.is_empty()


func _update_stack_buttons() -> void:
	var has_selection: bool = _get_selected_stack() != null
	_edit_stack_button.disabled = not has_selection
	_delete_stack_button.disabled = not has_selection


func _stack_by_name(stack_name: String) -> LibraryStack:
	for stack: LibraryStack in _stacks:
		if stack.name == stack_name:
			return stack
	return null


func _get_selected_stack() -> LibraryStack:
	if not _stack_tree:
		return null
	var item: TreeItem = _stack_tree.get_selected()
	if not item or item.get_metadata(0) == null:
		return null
	return _stack_by_name(String(item.get_metadata(0)))


func _on_stack_selected() -> void:
	_update_stack_buttons()


## Checks or unchecks a Stack (and its child library rows) so the Libraries tab
## selection stays in sync with the LibraryStacks tab.
func _on_stack_item_edited() -> void:
	var item: TreeItem = _stack_tree.get_edited()
	if not item:
		return
	var stack := _stack_by_name(String(item.get_metadata(0)))
	if not stack:
		return

	var lib_name: Variant = item.get_metadata(1)
	if lib_name != null:
		if item.is_checked(0):
			_check_dependencies_recursive(String(lib_name))
		else:
			_uncheck_dependents_recursive(String(lib_name))
	elif item.is_checked(0):
		_check_stack(stack)
	else:
		_uncheck_stack(stack)

	_update_status()
	_update_stack_check_states()


## Checks every library contained in `stack` (and its dependencies) so that
## switching to the Libraries tab shows them already selected.
func _check_stack(stack: LibraryStack) -> void:
	var applied: int = 0
	var missing: Array[String] = []
	for lib_name: String in stack.libraries:
		if _find_item_by_name(lib_name):
			_check_dependencies_recursive(lib_name)
			applied += 1
		else:
			missing.append(lib_name)
	if applied == 0 and not stack.libraries.is_empty():
		push_warning("Library Manager: none of the libraries in stack '%s' exist in storage." % stack.name)
	elif missing.size() > 0:
		push_warning(
			"Library Manager: stack '%s' references missing libraries: %s" % [stack.name, ", ".join(missing)]
		)


## Unchecks every library contained in `stack`, cascading to any dependents.
func _uncheck_stack(stack: LibraryStack) -> void:
	for lib_name: String in stack.libraries:
		if _find_item_by_name(lib_name):
			_uncheck_dependents_recursive(lib_name)


func _on_new_stack_pressed() -> void:
	_open_stack_dialog(null)


func _on_edit_stack_pressed() -> void:
	var stack := _get_selected_stack()
	if stack:
		_open_stack_dialog(stack)


func _open_stack_dialog(existing: LibraryStack) -> void:
	var names: Array[String] = []
	for lib: LibraryData in _libraries:
		names.append(lib.name)

	var taken: Array[String] = []
	for stack: LibraryStack in _stacks:
		if stack != existing:
			taken.append(stack.name)

	var dialog := LibraryStackDialog.open(self, names, existing, taken)
	if dialog:
		dialog.saved.connect(_on_stack_saved.bind(existing))


func _on_stack_saved(stack_name: String, libraries: Array[String], existing: LibraryStack) -> void:
	if existing:
		existing.name = stack_name
		existing.set_libraries(libraries)
	else:
		_stacks.append(LibraryStack.new(stack_name, libraries))
	LibraryStackStore.save_stacks(_storage_path, _stacks)
	_refresh_stack_tree()


func _on_delete_stack_pressed() -> void:
	var stack := _get_selected_stack()
	if not stack:
		return
	var confirm := LibraryConfirmDialog.open(
		self,
		"Delete LibraryStack",
		"Delete the LibraryStack '%s'?\n\nThis only removes the group, not the libraries." % stack.name,
		"Delete",
		"Cancel",
		true
	)
	confirm.confirmed.connect(_on_delete_stack_confirmed.bind(stack))


func _on_delete_stack_confirmed(stack: LibraryStack) -> void:
	_stacks.erase(stack)
	LibraryStackStore.save_stacks(_storage_path, _stacks)
	_refresh_stack_tree()


# ─── Checkbox cascade ─────────────────────────────────────────

func _on_tree_item_edited() -> void:
	var item: TreeItem = _tree.get_edited()
	if not item:
		return
	var lib_name: String = item.get_metadata(0)
	if item.is_checked(0):
		_check_dependencies_recursive(lib_name)
	else:
		_uncheck_dependents_recursive(lib_name)
	_update_status()
	_update_stack_check_states()


func _check_dependencies_recursive(lib_name: String) -> void:
	var item: TreeItem = _find_item_by_name(lib_name)
	if not item:
		push_warning("Library Manager: dependency not found: " + lib_name)
		return
	if not item.is_checked(0):
		item.set_checked(0, true)
	var deps: Array = item.get_metadata(1)
	for dep: String in deps:
		_check_dependencies_recursive(dep)


func _uncheck_dependents_recursive(lib_name: String) -> void:
	var self_item: TreeItem = _find_item_by_name(lib_name)
	if self_item and self_item.is_checked(0):
		self_item.set_checked(0, false)

	for dep_name: String in _find_dependents(lib_name):
		var dep_item: TreeItem = _find_item_by_name(dep_name)
		if dep_item and dep_item.is_checked(0):
			dep_item.set_checked(0, false)
			print("Library Manager: '%s' unchecked because it depends on '%s'." % [dep_name, lib_name])
			_uncheck_dependents_recursive(dep_name)


func _find_dependents(target: String) -> Array[String]:
	var result: Array[String] = []
	var root: TreeItem = _tree.get_root()
	if not root:
		return result
	var child: TreeItem = root.get_first_child()
	while child:
		var deps: Array = child.get_metadata(1)
		if deps.has(target):
			result.append(child.get_metadata(0))
		child = child.get_next()
	return result


func _find_item_by_name(lib_name: String) -> TreeItem:
	var root: TreeItem = _tree.get_root()
	if not root:
		return null
	var child: TreeItem = root.get_first_child()
	while child:
		if child.get_metadata(0) == lib_name:
			return child
		child = child.get_next()
	return null


# ─── Button handlers ──────────────────────────────────────────

func _on_refresh_pressed() -> void:
	_reload()


func _on_select_all_pressed() -> void:
	var root: TreeItem = _tree.get_root()
	if not root:
		return
	var child: TreeItem = root.get_first_child()
	while child:
		if child.is_visible():
			child.set_checked(0, true)
		child = child.get_next()
	_update_status()
	_update_stack_check_states()


func _on_deselect_all_pressed() -> void:
	var root: TreeItem = _tree.get_root()
	if not root:
		return
	var child: TreeItem = root.get_first_child()
	while child:
		child.set_checked(0, false)
		child = child.get_next()
	_update_status()
	_update_stack_check_states()


func _on_open_storage_pressed() -> void:
	if _storage_path != "" and DirAccess.dir_exists_absolute(_storage_path):
		OS.shell_open(_storage_path)
	else:
		push_warning("Library Manager: storage folder does not exist: " + _storage_path)


func _on_cancel_pressed() -> void:
	hide()


func _on_close_requested() -> void:
	hide()


func _on_apply_pressed() -> void:
	var selected: Array[String] = get_selected_libraries()
	var to_remove: Array[String] = get_libraries_to_remove()
	var gh_deps: Array[String] = get_github_dependencies_to_install()

	if selected.is_empty() and to_remove.is_empty() and gh_deps.is_empty():
		push_warning("Library Manager: nothing to apply.")
		return

	var errors: Array[String] = validate_selection()
	if errors.size() > 0:
		for e: String in errors:
			push_error("Library Manager: " + e)
		return

	apply_requested.emit(selected, to_remove, gh_deps)


func _on_update_from_storage_pressed() -> void:
	var selected: Array[String] = _filter_existing_in_project(get_selected_libraries())
	if selected.is_empty():
		push_warning("Library Manager: no libraries selected that exist in this project.")
		return
	update_requested.emit(selected)


func _on_push_to_storage_pressed() -> void:
	var selected: Array[String] = _filter_existing_in_project(get_selected_libraries())
	if selected.is_empty():
		push_warning("Library Manager: no libraries selected that exist in this project.")
		return
	push_requested.emit(selected)


## Returns only the libraries that physically exist in components_path.
func _filter_existing_in_project(libs: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for lib_name: String in libs:
		if _library_exists_in_project(lib_name):
			result.append(lib_name)
	return result


# ─── Queries & validation ─────────────────────────────────────

func get_selected_libraries() -> Array[String]:
	var result: Array[String] = []
	var root: TreeItem = _tree.get_root()
	if not root:
		return result
	var child: TreeItem = root.get_first_child()
	while child:
		if child.is_checked(0):
			result.append(child.get_metadata(0))
		child = child.get_next()
	return result


func get_libraries_to_remove() -> Array[String]:
	var result: Array[String] = []
	var selected: Array[String] = get_selected_libraries()
	for lib_name: String in _initially_present:
		if not selected.has(lib_name):
			result.append(lib_name)
	return result


func get_github_dependencies_to_install() -> Array[String]:
	var result: Array[String] = []
	var selected: Array[String] = get_selected_libraries()
	for lib: LibraryData in _libraries:
		if not selected.has(lib.name):
			continue
		for url: String in lib.github_dependencies:
			if not result.has(url):
				result.append(url)
	return result


func validate_selection() -> Array[String]:
	var errors: Array[String] = []
	var selected: Array[String] = get_selected_libraries()
	for lib_name: String in selected:
		var item: TreeItem = _find_item_by_name(lib_name)
		if not item:
			continue
		var deps: Array = item.get_metadata(1)
		for dep: String in deps:
			if not selected.has(dep):
				errors.append("'%s' requires '%s' but it is not checked." % [lib_name, dep])
	return errors
