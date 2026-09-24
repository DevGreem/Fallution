extends Node

class_name InputManagerComponent

func activate_all() -> void:
	for child: Node in get_children():
		
		if child is InputComponent:
			
			if child.ignore_manager:
				continue
			
			child.activate()

func deactivate_all() -> void:
	
	for child: Node in get_children():
		
		if child is InputComponent:
			
			if child.ignore_manager:
				continue
			
			child.deactivate()
