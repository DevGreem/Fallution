extends ModifierMode

class_name MultiplyBuffMode

func execute_buff(raw_value: float, buff_value: float, modified_value: float = raw_value) -> float:
	return modified_value + raw_value * buff_value
