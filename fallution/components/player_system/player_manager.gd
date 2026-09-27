extends Node

signal player_spawned()
signal player_died()
signal player_changed()

var current_player: Node2D = null:
	set(value):
		
		if current_player == value:
			return
		
		player_changed.emit(value)
		current_player = value

func set_player_spawned(player: Node) -> void:
	
	if current_player == player:
		return
	
	current_player = player
	player_spawned.emit()
	
	if not current_player.tree_exited.is_connected(_on_player_tree_exited):
		current_player.tree_exited.connect(_on_player_tree_exited)

func fake_kill_player() -> void:
	
	if not is_instance_valid(current_player):
		return
	
	player_died.emit()
	
	if current_player.tree_exited.is_connected(_on_player_tree_exited):
		current_player.tree_exited.disconnect(_on_player_tree_exited)
	
	current_player = null

func kill_player() -> void:
	
	if not is_instance_valid(current_player):
		return
	
	current_player.queue_free()
	player_died.emit()
	current_player = null

func _on_player_tree_exited() -> void:
	player_died.emit()
	current_player = null
