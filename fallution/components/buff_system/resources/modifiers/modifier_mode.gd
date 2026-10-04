@abstract
extends Resource

class_name ModifierMode

## Inputs: [raw_value: float, buff_value: float]
func _setup_expression(expression: String) -> Expression:
	
	var expr := Expression.new()
	
	var result: Error = expr.parse(expression, ["raw_value", "buff_value"])
	
	if result != Error.OK:
		return
	
	return expr

## Expression Inputs: [raw_value, buff_value] 
@abstract
func get_expression() -> Expression

func execute_buff(raw_value: float, buff_value: float) -> float:
	
	var expr: Expression = get_expression()
	
	if not expr:
		return raw_value
	
	var result: float = expr.execute([raw_value, buff_value], self)
	
	return result
