extends Resource

class_name ShareableResource

var _get_parent_properties_names_cache: Array[String] = []

func _get_parent_properties_names() -> Array[String]:
	
	if _get_parent_properties_names_cache.size() > 0:
		return _get_parent_properties_names_cache
	
	var base: Resource = Resource.new()
	var names: Array[String] = []
	
	for prop: Dictionary in base.get_property_list():
		names.append(prop["name"])
	
	_get_parent_properties_names_cache = names
	return names

func _is_prop(name: StringName) -> bool:
	
	if name.ends_with(".gd") or name.contains("cache") or name.contains("metadata"):
		return false
	
	return true

var _get_custom_properties_names_cache: Array[StringName] = []

func get_custom_properties_names() -> Array[StringName]:
	
	if _get_custom_properties_names_cache.size() > 0:
		return _get_custom_properties_names_cache
	
	var names: Array[String] = _get_parent_properties_names()
	
	var customs: Array[StringName] = []
	
	for prop: Dictionary in self.get_property_list():
		
		var name: StringName = prop["name"]
		
		if not _is_prop(name):
			continue
		
		if name not in names:
			customs.append(name)
	
	_get_custom_properties_names_cache = customs
	return customs

var _get_custom_properties_cache: Array[Dictionary] = []

func get_custom_properties() -> Array[Dictionary]:
	
	if _get_custom_properties_cache.size() > 0:
		return _get_custom_properties_cache
	
	var names: Array[String] = _get_parent_properties_names()
	
	var customs: Array[Dictionary] = []
	
	for prop: Dictionary in self.get_property_list():
		
		if not _is_prop(prop["name"] as String):
			continue
		
		if prop["name"] not in names:
			customs.append(prop)
	
	_get_custom_properties_cache = customs
	return customs

var _get_custom_properties_dict_cache: Dictionary = {}

func get_custom_properties_dict() -> Dictionary[String, Dictionary]:
	
	if _get_custom_properties_dict_cache.size() > 0:
		return _get_custom_properties_dict_cache
	
	var names: Array[String] = _get_parent_properties_names()
	
	var customs: Dictionary[String, Dictionary] = {}
	
	for prop: Dictionary in self.get_property_list():
		
		if not _is_prop(prop["name"] as String):
			continue
		
		if prop["name"] not in names:
			customs[prop["name"]] = prop
	
	_get_custom_properties_dict_cache = customs
	return customs

func is_custom_property(property_name: StringName) -> bool:
	return self.get_custom_properties_dict().has(property_name)

func get_custom_properties_values(deep: bool = true) -> Dictionary[String, Variant]:
	
	var values: Dictionary[String, Variant] = {}
	
	for prop: String in self.get_custom_properties_names():
		
		var value: Variant = self.get(prop)
		
		if deep:
			if value is ShareableResource:
				#print("Ejecutando el shareable resource sin array")
				value = value.get_custom_properties_values(true)
			
			if value is Array[ShareableResource]:
				#print("Ejecutando el shareable resource de array")
				var temp_arr: Array[Dictionary] = []
				for resource: Variant in value:
					temp_arr.append(resource.get_custom_properties_values(true))
				
				value = temp_arr
				
		values[prop] = value
	
	return values

func to_dict() -> Dictionary[String, Variant]:
	return get_custom_properties_values()

func from_dict(data: Dictionary[String, Variant]) -> void:
	
	for key: String in data:
		self.set(key, data[key])

static func from_dict_to_script(type: Script, data: Dictionary) -> ShareableResource:
	
	var object: Object = type.new()
	
	for key: String in data:
		object.set(key, data[key])
	
	return object

static func _make_key_value_string(key: String, value: Variant) -> String:
	return '"' + key + '": ' + str(value)

static func _make_dict_to_string(dict: Dictionary, indent: String = "", sort_keys: bool = true) -> String:
	
	var result: String = "{"
	
	if sort_keys:
		dict.sort()
	
	for key: String in dict:
		var value: Variant = dict[key]
		
		if indent != "":
			result += "\n" + indent
		
		result += _make_key_value_string(key, value)
	
	return result

func dict_to_string(indent: String = "", sort_keys: bool = true) -> String:
	
	return _make_dict_to_string(
		self.to_dict(),
		indent,
		sort_keys
	)

func _to_string() -> String:
	return JSON.stringify(self.to_dict(), "\t")
