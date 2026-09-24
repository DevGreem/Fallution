extends AudioRequester

class_name AudioStreamRequester

@export var stream: AudioStream

func _request_play() -> void:
	AudioManager.play_stream(stream)
