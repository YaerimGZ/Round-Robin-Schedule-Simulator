extends Node2D

signal transitioned
var scene : String
onready var animation = $LoadingScreen

func _ready():
	transition()

func transition():
	animation.play("Loading...")

#func newScene(newScene):
	#get_tree().change_scene(newScene)

func _on_LoadingScreen_animation_finished(animationName):
	if animationName == "Fading":
		emit_signal("transitioned")
		$"KO icon".queue_free()
		$Timer.queue_free()
		animation.play("Unfading")
		Global.goToScene(Global.nextScene)

func _on_Timer_timeout():
	$Loading.queue_free()
	$Loading2.queue_free()
	$Loading3.queue_free()
	$Loading4.queue_free()
	animation.stop()
	animation.play("Fading")
