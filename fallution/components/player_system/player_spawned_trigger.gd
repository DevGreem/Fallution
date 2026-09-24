@tool
extends ExecuteTrigger

class_name PlayerSpawnedTrigger

func _ready() -> void:
	
	if Engine.is_editor_hint():
		return
	
	node = PlayerManager
	signal_to_connect = PlayerManager.player_spawned.get_name()
	
	super._ready()
	GameDebugger.debug_log(PlayerSpawnedTrigger, "Connected PlayerManagerTrigger")

func _validate_property(property: Dictionary) -> void:
	super._validate_property(property)
	
	if property.name in ["node", "signal_to_connect"]:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func _get_configuration_warnings() -> PackedStringArray:
	return []
