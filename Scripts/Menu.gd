extends Control

export var intro_scene: PackedScene

func _ready():
	$AnimationPlayer.play("loop")
	$BestWaveLabel.text = "Best Wave: " + str(Global.best_wave)


func _on_StartButton_pressed():
	get_tree().change_scene_to(intro_scene)


func _on_QuitButton_pressed():
	get_tree().quit()
