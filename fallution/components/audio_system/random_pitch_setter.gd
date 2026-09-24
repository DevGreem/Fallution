@tool
extends Node

class_name RandomPitchSetter

@export var player: Variant:
	set(value):
		
		if "pitch_scale" not in value:
			GameDebugger.debug_error(RandomPitchSetter, "Trying set an invalid AudioStreamPlayer", true)
			return
		
		player = value
		
		if player:
			randomize_pitch()

@export var randomize_on_set: bool = true

@export var derivated: bool = true
@export var rand_range: Vector2 = Vector2(0, 1)

func randomize_pitch() -> void:
	
	if Engine.is_editor_hint():
		return
	
	if derivated:
		player.pitch_scale = randf_range(
			(player.pitch_scale - rand_range.x) as float,
			(player.pitch_scale + rand_range.y) as float
		)
		return
	
	player.pitch_scale = randf_range(rand_range.x, rand_range.y)

func _validate_property(property: Dictionary) -> void:
	
	if property.name == "player":
		property.type = TYPE_OBJECT
		property.hint = PROPERTY_HINT_NODE_TYPE
		property.hint_string = "AudioStreamPlayer,AudioStreamPlayer2D,AudioStreamPlayer3D"
