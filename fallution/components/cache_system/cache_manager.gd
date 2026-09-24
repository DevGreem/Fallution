extends RefCounted

class_name CacheManager

@warning_ignore("unused_signal")
signal cleared

var storage: Dictionary = {}:
	set(value):
		
		storage = value
		
		if storage == {}:
			cleared.emit()

var _getter_manager: CacheGetter:
	get = getter_manager,
	set = set_getter

var _storage_manager: CacheStorage:
	get = storage_manager,
	set = set_storage

var _garbage_manager: CacheGarbage:
	get = garbage_manager,
	set = set_garbage

func _init(
	getter: CacheGetter = CacheGetter.new(),
	storager: CacheStorage = CacheStorage.new(),
	garbager: CacheGarbage = CacheGarbage.new()
) -> void:
	_getter_manager = getter
	_storage_manager = storager
	_garbage_manager = garbager

func getter_manager() -> CacheGetter:
	return _getter_manager

func storage_manager() -> CacheStorage:
	return _storage_manager

func garbage_manager() -> CacheGarbage:
	return _garbage_manager

func set_getter(value: CacheGetter) -> void:
	
	_getter_manager = value
	
	if _getter_manager:
		_getter_manager.cache = self

func set_storage(value: CacheStorage) -> void:
	_storage_manager = value
	
	if _storage_manager:
		_storage_manager.cache = self

func set_garbage(value: CacheGarbage) -> void:
	_garbage_manager = value
	
	if _garbage_manager:
		_garbage_manager.cache = self
