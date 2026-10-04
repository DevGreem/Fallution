extends MoveComponent2D

class_name BuffableMoveComponent2d

@export var buff_manager: BuffManager

func _ready() -> void:
	
	if not buff_manager:
		buff_manager = ComponentManager.get_component(actor, BuffManager)

func _get_speed() -> float:
	
	if not buff_manager:
		return _speed
	
	var result: float = buff_manager.get_modified_value(SpeedBuff.new().get_id(), _speed)
	
	return result
