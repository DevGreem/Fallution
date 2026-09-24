extends AudioRequester

class_name AudioPlayerRequester

@export var player: AudioStreamPlayer

func _request_play() -> void:
	AudioManager.play_player(player)
