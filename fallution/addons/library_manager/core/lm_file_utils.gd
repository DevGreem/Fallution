@tool
class_name LMFileUtils
extends RefCounted

static func copy_directory_recursive(src: String, dst: String) -> bool:
	var dir: DirAccess = DirAccess.open(src)
	if not dir:
		push_error("Library Manager: could not open source folder: " + src)
		return false

	DirAccess.make_dir_recursive_absolute(dst)

	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if entry != "." and entry != "..":
			var src_path: String = src.path_join(entry)
			var dst_path: String = dst.path_join(entry)
			if dir.current_is_dir():
				if not copy_directory_recursive(src_path, dst_path):
					return false
			else:
				var err: Error = DirAccess.copy_absolute(src_path, dst_path)
				if err != OK:
					push_error("Library Manager: failed to copy %s -> %s (code %d)" % [src_path, dst_path, err])
					return false
		entry = dir.get_next()
	dir.list_dir_end()
	return true


static func copy_libraries(
	storage_path: String,
	dst_root: String,
	lib_names: Array
) -> Array[String]:
	var copied: Array[String] = []
	DirAccess.make_dir_recursive_absolute(dst_root)
	for lib_name: String in lib_names:
		var src: String = storage_path.path_join(lib_name)
		var dst: String = dst_root.path_join(lib_name)
		if copy_directory_recursive(src, dst):
			copied.append(lib_name)
	return copied


static func delete_directory_recursive(path: String) -> bool:
	if not DirAccess.dir_exists_absolute(path):
		return true
	var dir: DirAccess = DirAccess.open(path)
	if not dir:
		push_error("Library Manager: could not open folder to delete: " + path)
		return false

	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if entry != "." and entry != "..":
			var full: String = path.path_join(entry)
			if dir.current_is_dir():
				if not delete_directory_recursive(full):
					return false
			else:
				var err: Error = DirAccess.remove_absolute(full)
				if err != OK:
					push_error("Library Manager: failed to delete %s (code %d)" % [full, err])
					return false
		entry = dir.get_next()
	dir.list_dir_end()

	var err2: Error = DirAccess.remove_absolute(path)
	if err2 != OK:
		push_error("Library Manager: failed to delete folder %s (code %d)" % [path, err2])
		return false
	return true


static func delete_libraries(root: String, lib_names: Array) -> Array[String]:
	var deleted: Array[String] = []
	for lib_name: String in lib_names:
		var path: String = root.path_join(lib_name)
		if delete_directory_recursive(path):
			deleted.append(lib_name)
	return deleted


## Replaces several libraries at `dst_root` with fresh copies from
## `src_root`. Deletes each destination folder first, then copies, so
## that files removed at the source don't linger at the destination.
static func replace_libraries(
	src_root: String,
	dst_root: String,
	lib_names: Array
) -> Array[String]:
	var replaced: Array[String] = []
	DirAccess.make_dir_recursive_absolute(dst_root)
	for lib_name: String in lib_names:
		var src: String = src_root.path_join(lib_name)
		var dst: String = dst_root.path_join(lib_name)
		if DirAccess.dir_exists_absolute(dst):
			if not delete_directory_recursive(dst):
				push_error("Library Manager: could not clear '%s' before replacing." % lib_name)
				continue
		if copy_directory_recursive(src, dst):
			replaced.append(lib_name)
	return replaced
