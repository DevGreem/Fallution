extends CanvasItem

class_name InteractUI

@export var interact_component: InteractComponent2D
var focused: InteractArea2D

func _ready() -> void:
	
	if not interact_component:
		return
	
	if not interact_component.focused_interactable_changed.is_connected(_on_change_focus):
		interact_component.focused_interactable_changed.connect(_on_change_focus)
	
func _on_change_focus(area: InteractArea2D) -> void:
	
	if focused:
		_disconnect_interactable(focused)
	
	focused = area
	_connect_to_interactable(focused)
	
	toggle_visibility(focused)
	
func toggle_visibility(area: InteractArea2D) -> void:
	
	if not interact_component or not area:
		self.hide()
		return
	
	if not area.active or not interact_component.can_interact:
		self.hide()
		return
	
	self.show()

func _connect_to_interactable(area: InteractArea2D) -> void:
	
	if not area:
		return
	
	if not area.status_changed.is_connected(toggle_visibility.bind(area)):
		area.status_changed.connect(toggle_visibility.bind(area))

func _disconnect_interactable(area: InteractArea2D) -> void:
	
	if not area:
		return
	
	if area.status_changed.is_connected(toggle_visibility.bind(area)):
		area.status_changed.disconnect(toggle_visibility.bind(area))
