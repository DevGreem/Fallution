extends CacheManager

class_name ComponentCacheManager

func getter_manager() -> ComponentCacheGetter:
	return _getter_manager

func storage_manager() -> ComponentCacheStorage:
	return _storage_manager

func garbage_manager() -> ComponentCacheGarbage:
	return _garbage_manager
