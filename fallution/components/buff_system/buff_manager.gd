extends Node

class_name BuffManager

@export var _buffs: Dictionary[String, BuffStack] = {}

func get_buffs() -> Dictionary[String, BuffStack]:
	return _buffs

func get_buff_by_id(id: String) -> BuffStack:
	return _buffs[id]

func get_buff_by_type(type: BuffType) -> BuffStack:
	return get_buff_by_id(type.get_id())

func add_buff(buff: Buff) -> void:
	
	_add_key_if_not_exists(buff)
	
	_buffs[buff.type.get_id()].append_buff(buff)

func add_buffs(buffs: Array[Buff]) -> void:
	
	for buff: Buff in buffs:
		add_buff(buff)

func get_final_value(type: BuffType, value: float) -> float:
	
	if not _buffs.has(type.get_id()):
		return value
	
	var stack: BuffStack = _buffs[type.get_id()]
	
	var result: float = stack.get_final_value(value)
	
	return result

func clear_buff_id(id: String) -> bool:
	
	if not _buffs.has(id):
		return false
	
	_buffs[id].clear()
	return true

func clear_buff_type(type: BuffType) -> bool:
	return clear_buff_id(type.get_id())

func clear() -> void:
	_buffs.clear()

func _add_key_if_not_exists(buff: Buff) -> bool:
	
	var buff_id: String = buff.type.get_id()
	
	if _buffs.has(buff_id):
		return false
	
	_buffs[buff_id] = BuffStack.new()
	return true
