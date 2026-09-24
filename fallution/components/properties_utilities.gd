@tool
extends Node

func get_properties_names(properties: Array[Dictionary]) -> Array:
	return properties.map(
		func(property: Dictionary) -> StringName:
			return property.name
	)

func get_all_properties_names(object: Object, prefix: StringName = "", limit: int = 1) -> Array[StringName]:
	
	limit -= 1
	
	if limit == -1:
		return []
	
	var results: Array[StringName] = []
	
	for property: Dictionary in object.get_property_list():
		
		var property_name: StringName = property.name
		
		var path: StringName
		
		if prefix.is_empty():
			path = property_name
		else:
			path = prefix + ":" + property_name
		
		var val: Variant = object.get(property_name)
		
		if val is Object:
			results.append_array(
				get_all_properties_names(val as Object, path, limit)
			)
		
		results.append(path)
	
	return results

static func get_properties_path(object: Object, prefix: NodePath = NodePath(""), limit: int = 1) -> Array[NodePath]:
	
	limit -= 1
	
	if limit == -1:
		return []
	
	var result: Array[NodePath] = []
	
	for property: Dictionary in object.get_property_list():
		var property_name: StringName = property.name
		
		var path: NodePath
		
		if prefix.is_empty():
			path = NodePath(property_name)
		else:
			path = NodePath(str(prefix) + ":" + property_name)
		
		var val: Variant = object.get(property_name)
		
		if val is Object:
			result.append_array(
				get_properties_path(val as Object, path, limit)
			)
		
		result.append(path)
	
	return result
