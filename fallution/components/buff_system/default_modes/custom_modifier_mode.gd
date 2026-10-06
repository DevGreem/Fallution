extends ModifierMode

class_name CustomModifierMode

## Inputs: [raw_value: float, modified_value: float, buff_value: float]
@export_custom(PROPERTY_HINT_EXPRESSION, "") var _expression: String

## Inputs: [raw_value: float, modified_value: float, buff_value: float]
func _setup_expression(expression: String) -> Expression:
	
	var expr := Expression.new()
	
	var result: Error = expr.parse(expression, ["raw_value", "modified_value", "buff_value"])
	
	if result != Error.OK:
		return
	
	return expr

func execute_buff(raw_value: float, buff_value: float, modified_value: float = raw_value) -> float:
	
	var expr := _setup_expression(_expression)
	
	if not expr:
		return raw_value
	
	var result: float = expr.execute([raw_value, buff_value, modified_value])
	
	return result
