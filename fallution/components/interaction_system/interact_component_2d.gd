@tool
extends Node2D

class_name InteractComponent2D

signal interaction_added(area: InteractArea2D)
signal interaction_removed(area: InteractArea2D)
signal interacted(area: InteractArea2D)
signal focused_interactable_changed(area: InteractArea2D)

@export var actor: Node2D

@export var interact_area: Area2D:
	set(value):
		interact_area = value
		update_configuration_warnings()

@export var can_interact: bool = true

@export var can_interact_through_walls: bool = false

@export_flags_2d_physics var vision_blockers: int = 0

var detected_areas: Dictionary[InteractArea2D, bool] = {}
var focused_interactable: InteractArea2D:
	set(value):
		
		if focused_interactable == value:
			return
		
		if focused_interactable:
			focused_interactable.unfocus()
		
		focused_interactable = value
		focused_interactable_changed.emit(focused_interactable)
		
		if focused_interactable:
			focused_interactable.focus()
		
		GameDebugger.debug_log(InteractComponent2D, "Change focus to interactable = " + str(focused_interactable))

func _ready() -> void:
	
	if Engine.is_editor_hint():
		return
	
	if not interact_area.area_entered.is_connected(register_area):
		interact_area.area_entered.connect(register_area)
	
	if not interact_area.area_exited.is_connected(unregister_area):
		interact_area.area_exited.connect(unregister_area)

func _process(_delta: float) -> void:
	
	if Engine.is_editor_hint():
		return
	
	if not can_interact:
		return
	
	for area: InteractArea2D in detected_areas:
		
		if not is_instance_valid(area):
			unregister_area(area)
			continue
		
		if not area.active:
			detected_areas[area] = false
			
			if area == focused_interactable:
				focused_interactable = null
			
			continue
		
		detected_areas[area] = _can_reach(area)
	
	focused_interactable = _get_closer_interactable()

func register_area(area: InteractArea2D) -> bool:
	
	if not area.active:
		return false
	
	if detected_areas.has(area):
		return false
	
	detected_areas[area] = false
	interaction_added.emit(area)
	
	return true

func unregister_area(area: InteractArea2D) -> bool:
	
	if area == focused_interactable:
		focused_interactable = null
	
	var status: bool = detected_areas.erase(area)
	
	if status:
		interaction_removed.emit(area)
	
	return status

func interact() -> bool:
	
	if not can_interact or not focused_interactable:
		return false
	
	interacted.emit(focused_interactable)
	focused_interactable.interact(self)
	
	return true

func _get_closer_interactable() -> InteractArea2D:
	
	if detected_areas.is_empty():
		return null
	
	var best_area: InteractArea2D = null
	var best_distance: float = INF
	
	for area: InteractArea2D in detected_areas:
		
		if not detected_areas[area]:
			continue
		
		var distance: float = self.global_position.distance_to(area.global_position)
		
		if distance < best_distance:
			best_distance = distance
			best_area = area
	
	return best_area

func _can_reach(target: Node2D) -> bool:
	
	if can_interact_through_walls:
		return true
	
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		global_position,
		target.global_position
	)
	
	query.exclude = [self]
	query.collision_mask = vision_blockers
	
	var result: Dictionary = space.intersect_ray(query)
	
	if result.is_empty():
		return true
	
	return result.collider == target

func _get_configuration_warnings() -> PackedStringArray:
	
	var warnings: PackedStringArray = []
	
	if not interact_area:
		warnings.append("InteractComponent2D needs an Area2D!")
	
	return warnings
