extends Resource

class_name Buff

signal applied()
signal removed()
signal consumed()
signal consumed_time()
signal consumed_uses()

@export var ID: StringName

@export var effects: Array[BuffEffect] = []

## -1.0 = Infinity
@export var default_time: float = -1.0
var current_time: float = -1.0:
	set(value):
		
		current_time = value
		
		if current_time <= 0 and has_started:
			consumed_time.emit()
			_consume()

## -1 = Infinity
@export var default_uses: int = -1
var current_uses: int = -1:
	set(value):
		current_uses = value
		
		if current_uses <= 0 and has_started:
			consumed_uses.emit()
			_consume()

var _has_started := false
var has_started: bool:
	get: return _has_started
	set(value): return

func _init() -> void:
	reset_counters()

func reset_counters() -> void:
	current_time = default_time
	current_uses = default_uses
	_has_started = true

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
	return "Buff[%s]" % [ID]
