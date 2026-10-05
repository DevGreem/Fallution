extends Node

class_name BuffManager

@export var _inspector_buffs: Array[Buff] = []

var _buffs: Dictionary[StringName, ActiveBuff] = {}
@export var _modifiers: Dictionary[StringName, StatModifier] = {}

func _ready() -> void:
	
	if not _inspector_buffs.is_empty():
		
		for buff: Buff in _inspector_buffs:
			add_buff(buff)

func get_buffs() -> Dictionary[StringName, ActiveBuff]:
	return _buffs

func get_buff_by_id(id: StringName) -> ActiveBuff:
	return _buffs[id]

func add_buff(buff: Buff) -> void:
	
	var buff_id: StringName = buff.ID
	
	var instance: ActiveBuff
	
	if _buffs.has(buff_id):
		
		instance = _buffs[buff_id]
		instance.add_instance(buff)
		
		return
	
	instance = ActiveBuff.new()
	instance.add_instance(buff)
	
	_buffs[buff_id] = instance

## For future
func add_active_buff(instance_buff: ActiveBuff) -> void:
	
	var buff_id: StringName = instance_buff.get_buff_id()
	
	if not buff_id:
		return
	
	if _buffs.has(buff_id):
		var instance := _buffs[buff_id]
		
		for buff: Buff in instance_buff.instances:
			instance.add_instance(buff)
		
		return
	
	_buffs[buff_id] = instance_buff

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
