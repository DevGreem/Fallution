extends RefCounted

class_name ConnectionParameter

var callable: Callable
var flags: ConnectFlags = ConnectFlags.CONNECT_PERSIST

func _init(
	_callable: Callable = func() -> void: return,
	_flags: ConnectFlags = ConnectFlags.CONNECT_PERSIST
) -> void:
	callable = _callable
	flags = _flags

func connect_to(sig: Signal) -> bool:
	return SignalsUtilities.connect_signal(sig, callable, flags)

static func convert_callable(value: Callable) -> ConnectionParameter:
	return ConnectionParameter.new(value)

static func convert_callable_array(arr: Array[Callable]) -> Array[ConnectionParameter]:
	
	var new_arr: Array[ConnectionParameter] = []
	
	for val: Callable in arr:
		new_arr.append(convert_callable(val))
	
	GameDebugger.debug_log(ConnectionParameter, "New callable array: " + str(new_arr))
	return new_arr
