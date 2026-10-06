extends Resource

class_name BuffStack

@export var _buffs: Array[Buff] = []

func get_buffs() -> Array[Buff]:
	return _buffs

func use_buff_at(idx: int, times: float = 1.0) -> void:
	_buffs[idx].use(times)

func append_buff(buff: Buff) -> void:
	_buffs.append(buff)

func append_buffs(buffs: Array[Buff]) -> void:
	_buffs.append_array(buffs)

func order_insert_buff(buff: Buff) -> void:
	
	for i: int in range(_buffs.size()):
		
		if _buffs[i].priority < buff.priority:
			_buffs.insert(i-1, buff)
			break

func remove_buff_at(idx: int, free_buff: bool = false) -> void:
	
	var result: Buff = _buffs.pop_at(idx)
	
	if free_buff:
		result.free()

func remove_buff(buff: Buff) -> void:
	buff.remove(
		BuffContext.new(null, null, buff)
	)
	_buffs.erase(buff)

func clear() -> void:
	_buffs.clear()

func _on_complete_used_buff(buff: Buff) -> void:
	_buffs.erase(buff)
	buff.free()
