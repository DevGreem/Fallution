@tool
class_name LibraryData
extends RefCounted

var name: String = ""
var dependencies: Array[String] = []
var github_dependencies: Array[String] = []
var has_dependencies_file: bool = false


func _init(
	p_name: String = "",
	p_deps: Array[String] = [],
	p_gh: Array[String] = [],
	p_has_file: bool = false
) -> void:
	name = p_name
	dependencies = p_deps
	github_dependencies = p_gh
	has_dependencies_file = p_has_file


## Short display for the Dependencies column: local names + "gh:user/repo".
func dependencies_display() -> Array[String]:
	var result: Array[String] = []
	for d in dependencies:
		result.append(d)
	for gh in github_dependencies:
		result.append("gh:" + short_github(gh))
	return result


static func short_github(url: String) -> String:
	var u := url.strip_edges()
	if u.ends_with(".git"):
		u = u.substr(0, u.length() - 4)
	if u.ends_with("/"):
		u = u.substr(0, u.length() - 1)
	var tree_idx := u.find("/tree/")
	if tree_idx != -1:
		u = u.substr(0, tree_idx)
	var last := u.rfind("/")
	if last == -1:
		return u
	return u.substr(last + 1)
