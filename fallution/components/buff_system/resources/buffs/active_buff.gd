extends Resource

class_name ActiveBuff

@export var instances: Array[Buff] = []

func add_instance(buff: Buff) -> bool:
	
	if not instances.is_empty():
		
		if buff.ID != instances[0].ID:
			return false
	
	instances.append(buff)
	return true

func remove_instance(buff: Buff) -> bool:
	
	var idx := instances.find(buff)
	
	if idx == -1:
		return false
	
	instances.remove_at(idx)
	return true

func remove_instance_at(idx: int) -> void:
	instances.remove_at(idx)

func get_buff_id() -> StringName:
	
	if instances.is_empty():
		return ""
	
	return instances[0].ID
