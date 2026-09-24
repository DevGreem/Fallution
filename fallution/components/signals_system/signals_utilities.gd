extends RefCounted

class_name SignalsUtilities

static func connect_signal(target: Signal, callable: Callable, flags: ConnectFlags = ConnectFlags.CONNECT_PERSIST) -> bool:
	
	if target.is_connected(callable):
		return false
	
	target.connect(callable, flags)
	return true

static func disconnect_signal(target: Signal, callable: Callable) -> bool:
	
	if not target.is_connected(callable):
		return false
	
	target.disconnect(callable)
	return true

static func connect_callables_persist(target: Signal, callables: Array[Callable]) -> Array[bool]:
	return connect_callables(target, ConnectionParameter.convert_callable_array(callables))

static func connect_callables(target: Signal, callables: Array[ConnectionParameter]) -> Array[bool]:
	
	var results: Array[bool] = []
	
	for callable: ConnectionParameter in callables:
		var result: bool = callable.connect_to(target)
		results.append(result)
	
	return results

static func disconnect_callables(target: Signal, callables: Array[Callable]) -> Array[bool]:
	
	var results: Array[bool] = []
	
	for callable: Callable in callables:
		var result: bool = disconnect_signal(target, callable)
		results.append(result)
	
	return results

static func connect_signals_persist(connections: Dictionary[Signal, Array]) -> Dictionary[Signal, Array]:
	
	var results: Dictionary[Signal, Array] = {}
	
	for sig: Signal in connections:
		results[sig] = []
		
		var params: Array[Callable] = []
		params.assign(connections[sig])
		
		var arr: Array[bool] = connect_callables(
			sig,
			ConnectionParameter.convert_callable_array(params)
		)
		results[sig].assign(arr)
	
	return results

## [Dictionary] with keys as [Signal] and values as [Array] of [ConnectionParameter]
## Returns an [Dictionary] with keys as [Signal] and values as [Array] of [bool]
static func connect_signals(connections: Dictionary[Signal, Array]) -> Dictionary[Signal, Array]:
	
	var results: Dictionary[Signal, Array] = {}
	
	for sig: Signal in connections:
		results[sig] = connect_callables(sig, connections[sig])
	
	return results

## [Dictionary] with keys as [Signal] and values as [Array] of [Callable]
## Returns an [Dictionary] with keys as [Signal] and values as [Array] of [bool]
static func disconnect_signals(connections: Dictionary[Signal, Array]) -> Dictionary[Signal, Array]:
	
	var results: Dictionary[Signal, Array] = {}
	
	for sig: Signal in connections:
		results[sig] = disconnect_callables(sig, connections[sig])
	
	return results
