@tool
class_name LibraryService
extends Node

signal github_progress(url: String, message: String)
signal changed()
signal apply_finished()
signal update_finished()
signal push_finished()
signal remove_finished()
signal save_finished(success: bool, message: String)

var _installer: GitHubInstaller
var _pending_libs_to_add: Array = []
var _pending_storage_path := ""
var _pending_components_path := ""


func _init() -> void:
	_installer = GitHubInstaller.new()
	_installer.progress.connect(_on_installer_progress)
	_installer.all_finished.connect(_on_installer_all_finished)
	add_child(_installer)


func apply(libs_to_add: Array, libs_to_remove: Array, github_deps: Array) -> void:
	_pending_libs_to_add = libs_to_add
	_pending_storage_path = LibraryManagerSettings.get_storage_path()
	_pending_components_path = LibraryManagerSettings.get_absolute_components_path()

	if _pending_components_path == "":
		push_error("Library Manager: components path is not configured.")
		return

	if libs_to_remove.size() > 0:
		var deleted := LMFileUtils.delete_libraries(_pending_components_path, libs_to_remove)
		if deleted.size() > 0:
			print("Library Manager: deleted libraries: ", ", ".join(deleted))

	if github_deps.size() > 0:
		_installer.install_all(github_deps, _pending_storage_path, "res://addons")
	else:
		_copy_pending_libraries()


func update_from_storage(lib_names: Array) -> void:
	var replaced: Array[String] = LMFileUtils.replace_libraries(
		LibraryManagerSettings.get_storage_path(),
		LibraryManagerSettings.get_absolute_components_path(),
		lib_names
	)
	if replaced.size() > 0:
		print("Library Manager: updated from storage: ", ", ".join(replaced))
	else:
		push_warning("Library Manager: no libraries were updated.")
	changed.emit()
	update_finished.emit()


func push_to_storage(lib_names: Array) -> void:
	var pushed: Array[String] = LMFileUtils.replace_libraries(
		LibraryManagerSettings.get_absolute_components_path(),
		LibraryManagerSettings.get_storage_path(),
		lib_names
	)
	if pushed.size() > 0:
		print("Library Manager: pushed to storage: ", ", ".join(pushed))
	else:
		push_warning("Library Manager: no libraries were pushed.")
	push_finished.emit()


func remove_libraries(lib_names: Array) -> void:
	var storage_path := LibraryManagerSettings.get_storage_path()
	if storage_path == "":
		push_error("Library Manager: storage path is not configured.")
		return

	var deleted := LMFileUtils.delete_libraries(storage_path, lib_names)
	if deleted.size() > 0:
		print("Library Manager: deleted libraries: ", ", ".join(deleted))
		changed.emit()
	remove_finished.emit()


func save_library(source_path: String, lib_name: String) -> void:
	var abs_source := LibraryManagerSettings.globalize(source_path)
	var abs_dst := LibraryManagerSettings.get_storage_path().path_join(lib_name)

	if DirAccess.dir_exists_absolute(abs_dst):
		if not LMFileUtils.delete_directory_recursive(abs_dst):
			save_finished.emit(false, "failed to clear existing library '%s'." % lib_name)
			return

	if not LMFileUtils.copy_directory_recursive(abs_source, abs_dst):
		save_finished.emit(false, "failed to save library '%s'." % lib_name)
		return

	_ensure_dependencies_file(abs_dst, lib_name)
	print("Library Manager: saved library '%s' to %s" % [lib_name, abs_dst])
	save_finished.emit(true, "")


func _ensure_dependencies_file(library_path: String, lib_name: String) -> void:
	var deps_file := library_path.path_join("dependencies.txt")
	if FileAccess.file_exists(deps_file):
		return
	var f := FileAccess.open(deps_file, FileAccess.WRITE)
	if not f:
		return
	f.store_line("# Dependencies for " + lib_name)
	f.store_line("# One entry per line:")
	f.store_line("#   - another_library_name")
	f.store_line("#   - https://github.com/user/repo")
	f.close()


func _copy_pending_libraries() -> void:
	if _pending_libs_to_add.size() > 0:
		var copied: Array[String] = LMFileUtils.copy_libraries(
			_pending_storage_path,
			_pending_components_path,
			_pending_libs_to_add
		)
		if copied.size() > 0:
			print("Library Manager: copied libraries: ", ", ".join(copied))
	_pending_libs_to_add = []
	changed.emit()
	apply_finished.emit()


func _on_installer_progress(url: String, message: String) -> void:
	github_progress.emit(url, message)


func _on_installer_all_finished(results: Dictionary) -> void:
	for url in results.keys():
		var result: Dictionary = results[url]
		if not result.get("success", false):
			var error: String = result.get("error", "unknown")
			push_warning("Library Manager: failed to install %s (%s)" % [url, error])
	# Let the editor see the downloaded addons before copying libraries.
	changed.emit()
	_copy_pending_libraries()
