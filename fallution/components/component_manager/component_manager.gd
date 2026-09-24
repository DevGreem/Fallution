extends Node

## Dictionary of nodes with a dictionary of components and references to that component
## Example:
## [codeblock]
##	{
##		<ParentNode>: {
##			AnyType: [
##				<Node1>,
##				<Node2>
##			]
##		}
##	}
## [/codeblock]
var _cache: ComponentCacheManager = ComponentCacheManager.new(
	ComponentCacheGetter.new(),
	ComponentCacheStorage.new(),
	ComponentCacheGarbage.new()
)

## [param type] must be a type
func get_component(node: Node, type: Variant, internal: bool = false, use_cache: bool = true) -> Node:
	
	if not is_instance_valid(node):
		return null
	
	if use_cache:
		var cache: CacheStatusNode = _cache.getter_manager().get_component_cache(node, type)
		
		if cache.is_cached:
			return cache.get_value()
	
	for child: Node in node.get_children(internal):
		if is_instance_of(child, type):
			_cache.storage_manager().add_component_cache(node, type, child)
			return child
	
	#_add_component_cache(node, type, null)
	_cache.storage_manager().add_component_cache(node, type, null)
	return null

func recursive_get_component(parent: Node, node: Node, type: Variant, internal: bool = false, use_cache: bool = true) -> Node:
	
	if not is_instance_valid(parent) or not is_instance_valid(node):
		return null
	
	if use_cache:
		var cache: CacheStatusNode = _cache.getter_manager().get_component_cache(node, type)
		
		if cache.is_cached:
			return cache.get_value()
	
	for child: Node in node.get_children(internal):
		
		if is_instance_of(child, type):
			_cache.storage_manager().add_component_cache(parent, type, child)
			_cache.storage_manager().add_component_cache(node, type, child)
			return child
		
		var ans: Node = recursive_get_component(parent, child, type, internal, use_cache)
		
		if ans:
			_cache.storage_manager().add_component_cache(parent, type, child)
			_cache.storage_manager().add_component_cache(node, type, child)
			return ans
	
	_cache.storage_manager().add_component_cache(node, type, null)
	return null

func get_component_array(node: Node, type: Variant, internal: bool = false, use_cache: bool = true) -> Array[Node]:
	
	if not is_instance_valid(node):
		return []
	
	if use_cache:
		var cache: CacheStatusArrayNode = _cache.getter_manager().get_component_array_cache(node, type)
		
		if cache.is_cached:
			return cache.get_value()
	
	var result: Array[Node] = []
	
	for child: Node in node.get_children(internal):
		
		if is_instance_of(child, type):
			result.append(child)
			_cache.storage_manager().add_component_cache(node, type, child)
			continue
	
	if result.is_empty():
		_cache.storage_manager().add_component_cache(node, type, null)
	
	return result

func recursive_get_component_array(parent: Node, node: Node, type: Variant, internal: bool = false, use_cache: bool = true) -> Array[Node]:
	
	if not is_instance_valid(parent) or not is_instance_valid(node):
		return []
	
	if use_cache:
		var cache: CacheStatusArrayNode = _cache.getter_manager().get_component_array_cache(node, type)
		
		if cache.is_cached:
			return cache.get_value()
	
	var result: Array[Node] = []
	
	for child: Node in node.get_children(internal):
		
		if is_instance_of(child, type):
			result.append(child)
			_cache.storage_manager().add_component_cache(node, type, child)
			_cache.storage_manager().add_component_cache(parent, type, child)
		
		var ans: Array[Node] = recursive_get_component_array(parent, child, type, internal, use_cache)
		
		if ans:
			result.append_array(ans)
	
	if result.is_empty():
		_cache.storage_manager().add_component_cache(node, type, null)
	
	return result

## [parameter types] must be an array of types
func get_components(node: Node, types: Array, internal: bool = false) -> Dictionary[Variant, Node]:
	
	var answer: Dictionary[Variant, Node] = {}
	
	if not is_instance_valid(node) or types.is_empty():
		return answer
	
	for child: Node in node.get_children(internal):
		
		for type: Variant in types:
		
			if is_instance_of(child, type):
				#_add_component_cache(node, type, child)
				answer.set(type, child)
	
	return answer
