@tool
extends Camera2D

## This camera only works on debug engine
class_name DebugCamera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.is_debug_build():
		self.enabled = _is_owner_scene()
	else:
		self.enabled = false
		self.queue_free()

func _is_owner_scene() -> bool:
	return owner == get_tree().current_scene
