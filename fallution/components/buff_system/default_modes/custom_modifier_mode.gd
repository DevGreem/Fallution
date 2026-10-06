extends ModifierMode

class_name CustomModifierMode

@export_custom(PROPERTY_HINT_EXPRESSION, "") var _expression: String

func get_expression() -> Expression:
	return _setup_expression(_expression)
