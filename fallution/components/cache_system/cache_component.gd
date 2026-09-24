@abstract
extends RefCounted

class_name CacheComponent

var cache: CacheManager

func get_cache_manager() -> CacheManager:
	return cache
