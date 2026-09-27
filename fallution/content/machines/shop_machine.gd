extends Node2D

class_name ShopMachine

var _ui: Control

func _on_interacted(_component: InteractComponent2D) -> void:
	
	_ui = UIManager.open_file("")
	
func _on_ui_unfocused() -> void:
	
	if not _ui:
		return
	
	UIManager.close(_ui)
