extends Resource

class_name BuffStack

@export var _buffs: Array[Buff] = []
@export var auto_order: bool = false

func get_buffs() -> Array[Buff]:
	return _buffs

func use_buff_at(idx: int, times: float = 1.0) -> void:
	_buffs[idx].use(times)

func get_final_value(value: float) -> float:
	
	var result: float = value
	
	for buff: Buff in _buffs:
		result = buff.get_buff_value(result)
	
	return result

func _connect_buff(buff: Buff) -> void:
	
	var function: Callable = _on_complete_used_buff.bind(buff)
	
	if not buff.completed_used.is_connected(function):
		buff.completed_used.connect(function)

func append_buff(buff: Buff) -> void:
	_buffs.append(buff)
	_connect_buff(buff)
	
	if auto_order:
		order_buffs()

func append_buffs(buffs: Array[Buff]) -> void:
	_buffs.append_array(buffs)
	
	for buff: Buff in buffs:
		_connect_buff(buff)
	
	if auto_order:
		order_buffs()

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
	_buffs.erase(buff)

func clear() -> void:
	_buffs.clear()

func order_buffs() -> void:
	_buffs.sort_custom(_sort_by_priority)

func _sort_by_priority(a: Buff, b: Buff) -> bool:
	return a.priority < b.priority

func _on_complete_used_buff(buff: Buff) -> void:
	_buffs.erase(buff)
	buff.free()
