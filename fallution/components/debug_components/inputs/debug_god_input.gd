extends InputComponent

class_name DebugGodInput

@export var collisions: Array[CollisionShape2D]
var _disable: bool = true

func _input(event: InputEvent) -> void:
	
	if not OS.is_debug_build():
		return
	
	if event.is_action_pressed("debug_god"):
		
		for collision: CollisionShape2D in collisions:
			collision.disabled = _disable
		
		_disable = !_disable
