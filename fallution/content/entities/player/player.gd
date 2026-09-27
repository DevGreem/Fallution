@icon("res://addons/at-icons/node2d/human.svg")
extends CharacterBody2D

class_name PlayerNode

func _ready() -> void:
	PlayerManager.set_player_spawned(self)

func _exit_tree() -> void:
	PlayerManager.fake_kill_player()
