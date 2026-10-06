extends RefCounted

class_name ActiveBuff

var _instances: Array[Buff] = []

func process_instances(delta: float) -> void:
	for buff: Buff in _instances:
		buff.process(delta)

func get_instances() -> Array[Buff]:
	return _instances.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)

func add_instance(buff: Buff, context: BuffContext) -> bool:
	
	if not _instances.is_empty():
		
		if buff.ID != _instances[0].ID:
			return false
	
	_instances.append(buff)
	buff.apply(context)
	return true

func remove_instance(buff: Buff, context: BuffContext) -> bool:
	
	var idx := _instances.find(buff)
	
	if idx == -1:
		return false
	
	_instances.remove_at(idx)
	buff.remove(context)
	return true

func remove_instance_at(idx: int, context: BuffContext) -> void:
	var buff: Buff = _instances.pop_at(idx)
	
	if not buff:
		return
	
	buff.remove(context)

func clear(context: BuffContext) -> void:
	
	for i: int in range(len(_instances)):
		_instances[i].remove(context)
	
	_instances.clear()

func get_buff_id() -> StringName:
	
	if _instances.is_empty():
		return ""
	
	return _instances[0].ID
