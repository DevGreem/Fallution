extends Resource

class_name Buff

signal completed_used()

@export var type: BuffType
@export var value: float
@export var mode: BuffMode
@export var priority: int = 0

@export var default_uses: float = -1.0

var uses: float

func _init() -> void:
	uses = default_uses

func use(times: float) -> void:
	uses -= times
	
	if uses == 0:
		completed_used.emit()

func get_buff_value(raw_value: float) -> float:
	var final_value: float = mode.execute_buff(raw_value, value)
	return final_value
