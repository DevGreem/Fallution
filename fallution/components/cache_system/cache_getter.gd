extends CacheComponent

class_name CacheGetter

func _get_from_storage(...parameters: Array) -> Variant:
	
	if parameters.is_empty():
		return null
	
	var value: Variant = cache.storage[parameters[0]]
	
	for i: int in range(1, parameters.size()):
		var new_value: Variant = parameters[i]
		
		if not value.has(new_value):
			return null
		
		value = value[new_value]
	
	return value

func get_cache(...parameters: Array) -> BaseCacheStatus:
	
	var value: Variant = _get_from_storage.callv(parameters)
	
	if not value:
		return BaseCacheStatus.new(
			false,
			null
		)
	
	return value
