extends Resource

class_name Buff

signal applied()
signal removed()
signal consumed()
signal consumed_time()
signal consumed_uses()

@export var ID: StringName:
	set(value):
		if Engine.is_editor_hint():
			ID = value

@export var effects: Array[BuffEffect] = []

## -1.0 = Infinity
@export var default_time: float = -1.0
var current_time: float:
	set(value):
		
		if default_time == -1.0:
			return
		
		current_time = value
		
		if current_time <= 0:
			consumed_time.emit()
			_consume()

## -1 = Infinity
@export var default_uses: int = -1
var current_uses: int:
	set(value):
		
		if default_uses == -1:
			return
		
		current_uses = value
		
		if current_uses <= 0:
			consumed_uses.emit()
			_consume()

func _init() -> void:
	current_time = default_time
	current_uses = default_uses

func process(delta: float) -> void:
	
	if default_time == -1.0:
		return
	
	current_time -= delta
	
	if current_time <= 0.0:
		consumed_time.emit()
		_consume()
		return

func has_limit() -> bool:
	return default_uses != -1.0 or default_time != -1.0

func apply(context: BuffContext) -> void:
	
	for effect in effects:
		effect.apply(context)
	
	applied.emit()

func remove(context: BuffContext) -> void:
	
	for effect in effects:
		effect.remove(context)
	
	removed.emit()

func _consume() -> void:
	consumed.emit()

func _to_string() -> String:
	return "Buff[{0}]" % [ID]
