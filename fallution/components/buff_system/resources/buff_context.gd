extends RefCounted

class_name BuffContext

var target: Node
var source: Node
var buff: Buff
var is_consumed: bool = false

func _init(_target: Node, _source: Node, _buff: Buff) -> void:
	target = _target
	source = _source
	buff = _buff
