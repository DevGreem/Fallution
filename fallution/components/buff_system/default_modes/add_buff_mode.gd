extends BuffMode

class_name AddBuffMode

func get_expression() -> Expression:
	var expr := _setup_expression("raw_value + buff_value")
	return expr
