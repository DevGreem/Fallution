@tool
extends TextureRect

class_name StaticTextureArrow

signal target_changed(new: CanvasItem)

@export var active: bool = true
@export var auto_update: bool = true
@export var hide_on_unfocused: bool = true
@export var target: CanvasItem:
	set(value):
		
		if target == value:
			return
		
		target = value
		target_changed.emit(target)
		
		if auto_update:
			to_target()

@export var can_rotate: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if auto_update:
		to_target()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if auto_update:
		to_target()

func to_target() -> void:
	
	if not active:
		return
	
	if not is_instance_valid(target):
		
		if hide_on_unfocused:
			self.hide()
		
		return
	
	self.show()
	
	var target_center: Vector2 = get_pivot_global_position(target)
	
	rotation = get_pivot_global_position(self).direction_to(target_center).angle()

func get_pivot_global_position(node: CanvasItem) -> Vector2:
	
	if node is Control:
		return node.get_global_transform() * get_all_pivot_offset(node as Control)
	
	if node is Node2D:
		return node.get_global_transform().origin
	
	return Vector2.ZERO

func get_all_pivot_offset(node: Control) -> Vector2:
	
	if node.offset_transform_enabled:
		return node.offset_transform_pivot + node.offset_transform_pivot_ratio * node.size
	
	return node.get_combined_pivot_offset()

func _validate_property(property: Dictionary) -> void:
	
	if property.name == "target":
		property.hint_string = "Control,Node2D"
