@tool
class_name LibraryStackStore
extends RefCounted

## LibraryStacks are persisted as a JSON array inside the storage folder so
## they can be shared across every project that uses that storage.
const FILENAME := "library_stacks.json"


static func file_path(storage_path: String) -> String:
	return storage_path.path_join(FILENAME)


static func load_stacks(storage_path: String) -> Array[LibraryStack]:
	var result: Array[LibraryStack] = []
	if storage_path == "":
		return result
	var path := file_path(storage_path)
	if not FileAccess.file_exists(path):
		return result
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		push_warning("Library Manager: could not read stacks file: " + path)
		return result
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Array:
		push_warning("Library Manager: invalid stacks file: " + path)
		return result
	for entry: Variant in parsed:
		if entry is Dictionary:
			var stack := LibraryStack.from_dict(entry)
			if stack.name != "":
				result.append(stack)
	return result


static func save_stacks(storage_path: String, stacks: Array[LibraryStack]) -> bool:
	if storage_path == "":
		return false
	var data: Array = []
	for stack: LibraryStack in stacks:
		data.append(stack.to_dict())
	var f := FileAccess.open(file_path(storage_path), FileAccess.WRITE)
	if not f:
		push_error("Library Manager: could not write stacks file in " + storage_path)
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	return true
