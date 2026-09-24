@icon("res://addons/at-icons/node/pause.svg")
@tool
extends Node

class_name PauseGameInput

enum MenuOption {
	NONE,
	OPEN,
	INSTANTIATE
}

@export var menu_option: MenuOption:
	set(value):
		menu_option = value
		notify_property_list_changed()

@export var menu: CanvasItem
@export var menu_scene: PackedScene
@export var toggle_pause: bool = false

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("pause"):
		
		if toggle_pause:
			get_tree().paused = !get_tree().paused
		else:
			get_tree().paused = true
		
		_open_pause_menu()

func _open_pause_menu() -> void:
	
	if menu_option == MenuOption.NONE:
		return
	
	if menu_option == MenuOption.OPEN:
		menu.show()
		return
	
	if menu_option == MenuOption.INSTANTIATE:
		var instance: CanvasItem = menu_scene.instantiate()
		self.get_parent().add_child(instance)
		return

func _validate_property(property: Dictionary) -> void:
	
	if property.name == "menu":
		
		if menu_option != MenuOption.OPEN:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "menu_scene":
		
		if menu_option != MenuOption.INSTANTIATE:
			property.usage = PROPERTY_USAGE_NO_EDITOR
		
