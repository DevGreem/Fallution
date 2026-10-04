@tool
class_name LibraryStack
extends RefCounted

## A named group of libraries. The library names act as IDs (they match the
## folder names inside the storage folder).
var name: String = ""
var libraries: Array[String] = []


func _init(p_name: String = "", p_libraries: Array[String] = []) -> void:
	name = p_name
	set_libraries(p_libraries)


func set_libraries(p_libraries: Array[String]) -> void:
	libraries.clear()
	for lib: String in p_libraries:
		if not libraries.has(lib):
			libraries.append(lib)


func to_dict() -> Dictionary:
	return {"name": name, "libraries": libraries}


static func from_dict(data: Dictionary) -> LibraryStack:
	var libs: Array[String] = []
	var raw: Variant = data.get("libraries", [])
	if raw is Array:
		for lib: Variant in raw:
			libs.append(String(lib))
	return LibraryStack.new(String(data.get("name", "")), libs)
