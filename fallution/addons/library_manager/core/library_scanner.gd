@tool
class_name LibraryScanner
extends RefCounted

const DEPS_FILENAME := "dependencies.txt"


static func scan(storage_path: String) -> Array[LibraryData]:
	var result: Array[LibraryData] = []
	var dir := DirAccess.open(storage_path)
	if not dir:
		push_warning("Library Manager: could not open storage folder: " + storage_path)
		return result

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with("."):
			var lib_path := storage_path.path_join(entry)
			var deps_file := lib_path.path_join(DEPS_FILENAME)
			var local: Array[String] = []
			var gh: Array[String] = []
			var has_file := FileAccess.file_exists(deps_file)
			if has_file:
				var parsed := read_dependencies(deps_file)
				local = parsed["local"]
				gh = parsed["github"]
			result.append(LibraryData.new(entry, local, gh, has_file))
		entry = dir.get_next()
	dir.list_dir_end()
	return result


## Returns { "local": Array[String], "github": Array[String] }.
static func read_dependencies(deps_file: String) -> Dictionary:
	var local: Array[String] = []
	var gh: Array[String] = []
	var f := FileAccess.open(deps_file, FileAccess.READ)
	if not f:
		return {"local": local, "github": gh}
	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		if is_github_url(line):
			gh.append(line)
		else:
			local.append(line)
	f.close()
	return {"local": local, "github": gh}


static func is_github_url(s: String) -> bool:
	return s.begins_with("https://github.com/") \
		or s.begins_with("http://github.com/") \
		or s.begins_with("www.github.com/")
