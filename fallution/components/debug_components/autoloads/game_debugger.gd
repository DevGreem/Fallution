@tool
extends Node

func debug(title: Script, message: String, force_show: bool = false, type: DebugType.Enum = DebugType.Enum.LOG) -> void:
	
	if type == DebugType.Enum.LOG:
		debug_log(title, message, force_show)
	elif type == DebugType.Enum.WARNING:
		debug_warning(title, message, force_show)
	elif type == DebugType.Enum.ERROR:
		debug_error(title, message, force_show)

func debug_log(title: Script, message: String, force_show: bool = false) -> void:
	debug_log_string(title.get_global_name(), message, force_show)

func debug_log_string(title: String, message: String, force_show: bool = false) -> void:
	
	if OS.is_debug_build() or force_show:
		print(_format_message(title, message))

func debug_warning(title: Script, message: String, force_show: bool = false) -> void:
	debug_warning_string(title.get_global_name(), message, force_show)

func debug_warning_string(title: String, message: String, force_show: bool = false) -> void:
	
	if OS.is_debug_build() or force_show:
		push_warning(_format_message(title, message))

func debug_error(title: Script, message: String, force_show: bool = false) -> void:
	debug_error_string(title.get_global_name(), message, force_show)

func debug_error_string(title: String, message: String, force_show: bool = false) -> void:
	
	if OS.is_debug_build() or force_show:
		push_error(_format_message(title, message))

func _format_message(title: String, message: String) -> String:
	return title.strip_edges() + ": " + message
