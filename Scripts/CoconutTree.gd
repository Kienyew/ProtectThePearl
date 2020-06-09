extends Node2D

export(PackedScene) var coconut_scene
export var base_drop_interval: float

func _ready():
	$CoconutDropTimer.wait_time = base_drop_interval

func drop_coconut():
	var coconut = coconut_scene.instance()
	coconut.rotation = rand_range(0, TAU)
	var s = rand_range(0.9, 1.1)
	coconut.scale = Vector2(s, s) 
	add_child(coconut)
	coconut.start_dropping()

func _on_CoconutDropTimer_timeout():
	$CoconutDropTimer.wait_time = base_drop_interval + rand_range(-1.0, 1.0)
	drop_coconut()
