extends Node

var currentScene = null
var nextScene = ""

func _ready():
	
	var root = get_tree().get_root()
	currentScene = root.get_child((root.get_child_count() - 1))
	
func goToScene(path):
	call_deferred("_deferred_goto_scene", path)
	
func _deferred_goto_scene(path):
	currentScene.free()
	var s = ResourceLoader.load("res://Scenes/Lists.tscn")
	currentScene = s.instance()
	get_tree().get_root().add_child(currentScene)
	get_tree().set_current_scene(currentScene)
