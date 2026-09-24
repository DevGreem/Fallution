extends Control

@export var _transition_container: CanvasItem
@export var animation_in: AnimationPlayer
@export var animation_out: AnimationPlayer

const NAME: String = "TransitionManager"

func display_transition() -> void:
	_transition_container.show()

func stash_transition() -> void:
	_transition_container.hide()

func transition_in() -> bool:
	
	if not animation_in:
		return false
	
	if not animation_in.has_animation("in"):
		GameDebugger.debug_error_string(NAME, "Animation Player don't have the animation out")
		return false
	
	animation_in.play("in")
	await animation_in.animation_finished
	
	return true

func transition_out() -> bool:
	
	if not animation_out:
		return false
	
	if not animation_out.has_animation("out"):
		GameDebugger.debug_error_string(NAME, "Animation player don't have the animation out")
		return false
	
	animation_out.play("out")
	await animation_out.animation_finished
	
	return true

func transition(type: CustomEaseType.Enum) -> Array[bool]:
	
	if type == CustomEaseType.Enum.IN:
		return [await transition_in()]
	
	if type == CustomEaseType.Enum.OUT:
		return [await transition_out()]
	
	if type == CustomEaseType.Enum.IN_OUT:
		return [
			await transition_in(),
			await transition_out()
		]
	
	if type == CustomEaseType.Enum.OUT_IN:
		return [
			await transition_out(),
			await transition_in()
		]
	
	return [false]
