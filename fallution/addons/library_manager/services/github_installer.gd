@tool
class_name GitHubInstaller
extends Node

signal progress(url: String, message: String)
signal finished(url: String, plugin_name: String, success: bool)
signal all_finished(results: Dictionary)

const REGISTRY_FILENAME := "github_installed.json"
const TMP_DIR_NAME := "library_manager_tmp"

var _http: HTTPRequest
var _queue: Array[String] = []
var _current_url: String = ""
var _storage_path: String = ""
var _install_root: String = "res://addons"
var _results: Dictionary = {}
var _registry: Dictionary = {}


func _init() -> void:
	_http = HTTPRequest.new()
	_http.use_threads = true
	_http.timeout = 30.0
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)


## urls: GitHub repo URLs to install. Skips those already present.
## storage_path: where to persist the URL -> plugin_name registry.
## install_root: usually "res://addons".
func install_all(urls: Array, storage_path: String, install_root: String = "res://addons") -> void:
	_queue.clear()
	for u in urls:
		if not _queue.has(u):
			_queue.append(u)
	_storage_path = storage_path
	_install_root = install_root
	_results.clear()
	_load_registry()
	_process_next()


# ─── Queue ────────────────────────────────────────────────────

func _process_next() -> void:
	if _queue.is_empty():
		all_finished.emit(_results)
		return
	_current_url = _queue.pop_front()

	# Already installed?
	var cached_name := _get_cached_name(_current_url)
	if cached_name != "":
		var abs_path := ProjectSettings.globalize_path(_install_root.path_join(cached_name))
		if DirAccess.dir_exists_absolute(abs_path):
			progress.emit(_current_url, "already installed as '%s'" % cached_name)
			_results[_current_url] = {"success": true, "name": cached_name, "skipped": true}
			finished.emit(_current_url, cached_name, true)
			_process_next()
			return

	var archive_url := _to_archive_url(_current_url)
	if archive_url == "":
		progress.emit(_current_url, "invalid GitHub URL")
		_results[_current_url] = {"success": false, "name": "", "error": "invalid URL"}
		finished.emit(_current_url, "", false)
		_process_next()
		return

	progress.emit(_current_url, "downloading...")
	var err := _http.request(archive_url)
	if err != OK:
		progress.emit(_current_url, "request failed (%d)" % err)
		_results[_current_url] = {"success": false, "name": "", "error": "request failed"}
		finished.emit(_current_url, "", false)
		_process_next()


func _on_request_completed(
	result: int,
	code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	if _current_url == "":
		return
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		progress.emit(_current_url, "HTTP %d" % code)
		_results[_current_url] = {"success": false, "name": "", "error": "HTTP %d" % code}
		finished.emit(_current_url, "", false)
		_process_next()
		return

	if not _extract_and_install(body):
		if not _results.has(_current_url):
			_results[_current_url] = {"success": false, "name": "", "error": "install failed"}
			finished.emit(_current_url, "", false)
	_process_next()


# ─── Extraction + install ─────────────────────────────────────

func _extract_and_install(zip_bytes: PackedByteArray) -> bool:
	var tmp_root := OS.get_temp_dir().path_join(TMP_DIR_NAME)
	var extract_dir := tmp_root.path_join("extracted")

	if DirAccess.dir_exists_absolute(extract_dir):
		LMFileUtils.delete_directory_recursive(extract_dir)
	DirAccess.make_dir_recursive_absolute(extract_dir)

	# Write ZIP to disk.
	var zip_path := tmp_root.path_join("download.zip")
	var f := FileAccess.open(zip_path, FileAccess.WRITE)
	if not f:
		progress.emit(_current_url, "could not write ZIP")
		return false
	f.store_buffer(zip_bytes)
	f.close()

	if not _unzip(zip_path, extract_dir):
		progress.emit(_current_url, "could not extract ZIP")
		return false

	var found := _find_plugin_cfg(extract_dir)
	if found.is_empty():
		progress.emit(_current_url, "no plugin.cfg found in repository")
		return false

	var plugin_name: String = found["name"]
	var source_path: String = found["path"]

	var dst := ProjectSettings.globalize_path(_install_root.path_join(plugin_name))
	if DirAccess.dir_exists_absolute(dst):
		LMFileUtils.delete_directory_recursive(dst)
	if not LMFileUtils.copy_directory_recursive(source_path, dst):
		progress.emit(_current_url, "could not copy into addons")
		return false

	_registry[_current_url] = {"name": plugin_name}
	_save_registry()

	progress.emit(_current_url, "installed as '%s'" % plugin_name)
	_results[_current_url] = {"success": true, "name": plugin_name, "skipped": false}
	finished.emit(_current_url, plugin_name, true)
	return true


func _unzip(zip_path: String, dst_dir: String) -> bool:
	var reader := ZIPReader.new()
	var err := reader.open(zip_path)
	if err != OK:
		push_error("Library Manager: ZIPReader.open failed: %d" % err)
		return false
	var files := reader.get_files()
	for fname in files:
		if fname.ends_with("/"):
			continue
		var data := reader.read_file(fname)
		var out_path := dst_dir.path_join(fname)
		DirAccess.make_dir_recursive_absolute(out_path.get_base_dir())
		var out := FileAccess.open(out_path, FileAccess.WRITE)
		if not out:
			push_error("Library Manager: could not write " + out_path)
			reader.close()
			return false
		out.store_buffer(data)
		out.close()
	reader.close()
	return true


func _find_plugin_cfg(extract_root: String) -> Dictionary:
	var candidates: Array[String] = []
	_collect_plugin_cfgs(extract_root, candidates)
	if candidates.is_empty():
		return {}

	# ZIP root folder name (e.g. "repo-main").
	var zip_root_name := ""
	var dir := DirAccess.open(extract_root)
	if dir:
		dir.list_dir_begin()
		var entry := dir.get_next()
		while entry != "":
			if dir.current_is_dir():
				zip_root_name = entry
				break
			entry = dir.get_next()
		dir.list_dir_end()

	# Prefer candidates inside an addons/ folder.
	var chosen := ""
	for p in candidates:
		if p.contains("/addons/"):
			chosen = p
			break
	if chosen == "":
		chosen = candidates[0]

	var plugin_folder := chosen.get_base_dir()
	var plugin_name := plugin_folder.get_file()

	# If plugin.cfg sits at the ZIP root, fall back to the repo name.
	if plugin_name == zip_root_name or plugin_folder == extract_root:
		plugin_name = _repo_name_from_url(_current_url)

	return {"name": plugin_name, "path": plugin_folder}


func _collect_plugin_cfgs(dir_path: String, out: Array[String]) -> void:
	var dir := DirAccess.open(dir_path)
	if not dir:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry != "." and entry != ".." and not entry.begins_with("."):
			var full := dir_path.path_join(entry)
			if dir.current_is_dir():
				_collect_plugin_cfgs(full, out)
			elif entry == "plugin.cfg":
				out.append(full)
		entry = dir.get_next()
	dir.list_dir_end()


# ─── URL helpers ──────────────────────────────────────────────

func _to_archive_url(repo_url: String) -> String:
	var u := repo_url.strip_edges()
	if u.ends_with(".git"):
		u = u.substr(0, u.length() - 4)
	if u.ends_with("/"):
		u = u.substr(0, u.length() - 1)

	var branch := "main"
	var tree_idx := u.find("/tree/")
	if tree_idx != -1:
		branch = u.substr(tree_idx + 6)
		u = u.substr(0, tree_idx)

	if not u.begins_with("https://github.com/"):
		return ""
	var rest := u.substr(19)
	var parts := rest.split("/")
	if parts.size() < 2:
		return ""
	return "https://github.com/%s/%s/archive/refs/heads/%s.zip" % [parts[0], parts[1], branch]


func _repo_name_from_url(url: String) -> String:
	var u := url.strip_edges()
	if u.ends_with(".git"):
		u = u.substr(0, u.length() - 4)
	if u.ends_with("/"):
		u = u.substr(0, u.length() - 1)
	var tree_idx := u.find("/tree/")
	if tree_idx != -1:
		u = u.substr(0, tree_idx)
	var last := u.rfind("/")
	if last == -1:
		return u
	return u.substr(last + 1)


# ─── Registry ─────────────────────────────────────────────────

func _registry_path() -> String:
	return _storage_path.path_join(REGISTRY_FILENAME)


func _load_registry() -> void:
	_registry = {}
	var p := _registry_path()
	if not FileAccess.file_exists(p):
		return
	var f := FileAccess.open(p, FileAccess.READ)
	if not f:
		return
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if parsed is Dictionary:
		_registry = parsed


func _save_registry() -> void:
	var f := FileAccess.open(_registry_path(), FileAccess.WRITE)
	if not f:
		return
	f.store_string(JSON.stringify(_registry, "\t"))
	f.close()


func _get_cached_name(url: String) -> String:
	if _registry.has(url):
		var entry = _registry[url]
		if entry is Dictionary:
			return entry.get("name", "")
	return ""
