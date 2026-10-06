extends RefCounted

class_name ActiveBuff

var instances: Array[Buff] = []

func process_instances(delta: float) -> void:
	for buff: Buff in instances:
		buff.process(delta)

func add_instance(buff: Buff, context: BuffContext) -> bool:
	
	if not instances.is_empty():
		
		if buff.ID != instances[0].ID:
			return false
	
	instances.append(buff)
	buff.apply(context)
	return true

func remove_instance(buff: Buff, context: BuffContext) -> bool:
	
	var idx := instances.find(buff)
	
	if idx == -1:
		return false
	
	instances.remove_at(idx)
	buff.remove(context)
	return true

func remove_instance_at(idx: int, context: BuffContext) -> void:
	var buff: Buff = instances.pop_at(idx)
	buff.remove(context)

func clear(context: BuffContext) -> void:
	
	for i: int in range(len(instances)):
		instances[i].remove(context)
	
	instances.clear()

func get_buff_id() -> StringName:
	
	if instances.is_empty():
		return ""
	
	return instances[0].ID
