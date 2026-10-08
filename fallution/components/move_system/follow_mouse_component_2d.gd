@icon("res://addons/at-icons/node2d/cursor.svg")
@tool
extends Node2D

class_name FollowMouseComponent2D

@export var actor: Node2D:
	set(value):
		
		actor = value
		
		if actor:
			actor_original_position = actor.position

## Max distance since the actor initial position
@export var max_distance := -Vector2.ONE:
	set(value):
		max_distance = value
		queue_redraw()

@export var color := Color.from_rgba8(255, 255, 0, 107):
	set(value):
		color = value
		queue_redraw()

var actor_original_position: Vector2

func _physics_process(_delta: float) -> void:
	
	if not actor or Engine.is_editor_hint():
		return
	
	var mouse_pos := actor.get_global_mouse_position()
	
	var actor_parent: Node = actor.get_parent()
	
	var target_pos := Vector2.ZERO
	
	if actor_parent.has_method("to_local"):
		target_pos = actor_parent.to_local(mouse_pos)
	
	var offset := target_pos - actor_original_position
	
	if max_distance != -Vector2.ONE:
		offset = offset.clamp(-max_distance, max_distance)
	
	target_pos = actor_original_position + offset
	actor.position = target_pos

func _draw() -> void:
	
	if not Engine.is_editor_hint():
		return
	
	if not actor or max_distance == -Vector2.ONE:
		return
	
	var center := to_local(actor.global_position)
	
	draw_rect(
		Rect2(center - max_distance, max_distance * 2),
		color
	)
