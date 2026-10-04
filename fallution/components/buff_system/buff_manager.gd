extends Node

class_name BuffManager

@export var _buffs: Dictionary[StringName, Buff] = {}
@export var _modifiers: Dictionary[StringName, StatModifier] = {}

func get_buffs() -> Dictionary[StringName, Buff]:
	return _buffs

func get_buff_by_id(id: StringName) -> Buff:
	return _buffs[id]

func add_buff(buff: Buff) -> void:
	
	var buff_id: StringName = buff.ID
	
	if _buffs.has(buff_id):
		pass
	
	_buffs[buff_id] = buff

## For future
func add_active_buff(buff: Buff) -> void:
	pass

func add_buffs(buffs: Array[Buff]) -> void:
	
	for buff: Buff in buffs:
		add_buff(buff)

func get_modified_value(type: StringName, raw_value: float) -> float:
	
	var modifiers := _modifiers[type]
	
	var result := raw_value
	
	for modifier: StatModifier in modifiers:
		
		result = modifier.get_value_modified(raw_value)
	
	return result

func add_modifier(modifier: StatModifier) -> void:
	
	_modifiers[modifier.type.get_id()] = modifier

func clear_modifier(id: StringName) -> void:
	_modifiers[id]

func clear_buff_id(id: String) -> bool:
	
	if not _buffs.has(id):
		return false
	
	_buffs[id].clear()
	return true

func clear() -> void:
	_buffs.clear()

func _add_key_if_not_exists(buff: Buff) -> bool:
	
	var buff_id: String = buff.ID
	
	if _buffs.has(buff_id):
		return false
	
	_buffs[buff_id] = buff
	return true
