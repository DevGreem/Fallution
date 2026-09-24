@abstract
extends Node

class_name InputComponent

@warning_ignore("unused_signal")
signal input_detected

@export var original_process: Node.ProcessMode
@export var actor: Node2D
var is_active: bool:
	get: return self.process_mode != PROCESS_MODE_DISABLED

@export var ignore_manager: bool = false

func _ready() -> void:
	original_process = self.process_mode

func activate() -> void:
	self.process_mode = self.original_process

func deactivate() -> void:
	self.process_mode = Node.PROCESS_MODE_DISABLED
