extends Node

## -1 for infinite
@export var _max_audio_players: int = -1:
	set(value):
		if value == 0:
			_max_audio_players = -1
			return
		
		_max_audio_players = value

var max_audio_players: int:
	get: return _max_audio_players
	set(value): return

func _ready() -> void:
	
	for i: int in range(0, max_audio_players):
		_add_new_player()

func play_stream(stream: AudioStream) -> bool:
	
	var player: AudioStreamPlayer = _get_first_free_player()
	
	if not player:
		return false
	
	player.stream = stream
	player.play()
	return true

func play_player(player: AudioStreamPlayer) -> bool:
	
	if max_audio_players > -1:
		return false
	
	if not player:
		return false
	
	var new_player: AudioStreamPlayer = player.duplicate(true)
	add_child(new_player)
	
	_connect_player_signals(new_player)
	new_player.play()
	return true

func _get_first_free_player() -> AudioStreamPlayer:
	
	if max_audio_players <= -1:
		return _add_new_player()
	
	for player: Node in get_children():
		
		if player is AudioStreamPlayer:
			
			if not player.playing:
				return player
	
	return null

func _add_new_player() -> AudioStreamPlayer:
	var new_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(new_player)
	
	if max_audio_players == -1:
		_connect_player_signals(new_player)
	
	return new_player

func _connect_player_signals(player: AudioStreamPlayer) -> void:
	player.finished.connect(_on_finish_player.bind(player))

func _on_finish_player(player: AudioStreamPlayer) -> void:
	player.queue_free()
