extends Node

class_name BuffManager

@export var _inspector_buffs: Array[Buff] = []
@export var _inspector_modifiers: Array[StatModifier] = []

var _buffs: Dictionary[StringName, ActiveBuff] = {}
var _modifiers: Dictionary[StringName, ModifiersStack] = {}

func _ready() -> void:
	
	if not _inspector_buffs.is_empty():
		
		for buff: Buff in _inspector_buffs:
			add_buff(buff)
	
	if not _inspector_modifiers.is_empty():
		
		for modifier: StatModifier in _inspector_modifiers:
			add_modifier(modifier)

func _process(delta: float) -> void:
	
	for buff_id: StringName in _buffs:
		_buffs[buff_id].process_instances(delta)

#region Buffs

func get_buffs() -> Dictionary[StringName, ActiveBuff]:
	return _buffs

func get_buff_by_id(id: StringName) -> ActiveBuff:
	return _buffs[id]

func _on_consumed_buff(buff: Buff) -> void:
	
	print("Removing buff ", buff, " (", buff.ID, ") from the buff manager ", self)
	
	var context := BuffContext.new(
		self,
		self,
		buff
	)
	context.is_consumed = true
	
	_buffs[buff.ID].remove_instance(buff, context)
	
	print("Buff removed.")

func add_buff(buff: Buff, context: BuffContext = null) -> void:
	
	if not buff:
		return
	
	print("Adding the buff ", buff, " to buff manager ", self)
	
	buff = buff.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	
	if not buff.has_started:
		buff.reset_counters()
	
	var callable := _on_consumed_buff.bind(buff)
	
	if not buff.consumed.is_connected(callable):
		buff.consumed.connect(callable, ConnectFlags.CONNECT_ONE_SHOT)
	
	var buff_id: StringName = buff.ID
	
	var instance: ActiveBuff
	
	if not context:
		context = BuffContext.new(
			self,
			self,
			buff
		)
	
	if _buffs.has(buff_id):
		
		instance = _buffs[buff_id]
		instance.add_instance(buff, context)
		
		return
	
	instance = ActiveBuff.new()
	instance.add_instance(buff, context)
	
	_buffs[buff_id] = instance

func add_active_buff(instance_buff: ActiveBuff, context: BuffContext = null) -> void:
	
	var buff_id: StringName = instance_buff.get_buff_id()
	
	if not buff_id:
		return
	
	if not context:
		context = BuffContext.new(
			self,
			self,
			null
		)
	
	if _buffs.has(buff_id):
		var instance := _buffs[buff_id]
		
		for buff: Buff in instance_buff.instances:
			context.buff = buff
			instance.add_instance(buff, context)
		
		return
	
	_buffs[buff_id] = instance_buff

func clear_buff_id(id: String, context: BuffContext = null) -> bool:
	
	if not _buffs.has(id):
		return false
	
	if not context:
		context = BuffContext.new(
			self,
			null,
			null
		)
	
	_buffs[id].clear(context)
	_buffs.erase(id)
	return true

#endregion

#region Modifiers

func get_modified_value(type: StringName, raw_value: float) -> float:
	
	print("Getting a new modified value of type ", type, " and value = ", raw_value)
	
	var stack: ModifiersStack = _modifiers.get(type, null)
	
	if not stack:
		print("This type don't have a stack assigned")
		return raw_value
	
	print("Getted stack: ", stack)
	
	var new_value := stack.get_modified_value(raw_value)
	print("New value with modifiers: ", new_value)
	
	return new_value

func add_modifier(modifier: StatModifier) -> void:
	var modifier_id := modifier.type.get_id()
	
	if _modifiers.has(modifier_id):
		_modifiers[modifier_id].add_modifier(modifier)
		return
	
	_modifiers[modifier_id] = ModifiersStack.new()
	_modifiers[modifier_id].add_modifier(modifier)

func remove_modifier(modifier: StatModifier) -> bool:
	
	var modifier_id := modifier.type.get_id()
	
	if not _modifiers.has(modifier_id):
		return false
	
	var idx := _modifiers[modifier_id].modifiers.find(modifier)
	if idx == -1:
		return false
	
	_modifiers[modifier.type.get_id()].modifiers.remove_at(idx)
	return true

func clear_modifier_type(id: StringName) -> void:
	_modifiers[id].modifiers.clear()

func clear_modifiers() -> void:
	_modifiers.clear()

#endregion

func clear() -> void:
	_buffs.clear()
	_modifiers.clear()
