extends Label

class_name FpsLabel

func _process(_delta: float) -> void:
	
	self.text = str(Engine.get_frames_per_second())
