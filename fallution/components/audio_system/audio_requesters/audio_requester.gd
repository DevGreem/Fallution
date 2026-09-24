@abstract
extends Node

class_name AudioRequester

signal play_requested

@abstract
func _request_play() -> void

func request_play() -> void:
	GameDebugger.debug_log(AudioRequester, "Requesting audio play")
	_request_play()
	play_requested.emit()
