extends Control

class_name UIRoot

func _ready() -> void:
	UIManager.root = self

func _exit_tree() -> void:
	UIManager.root = null
