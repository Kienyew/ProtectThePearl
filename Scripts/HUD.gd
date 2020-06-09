extends Node

func update_pearl_count():
	var pearl_count = 0
	pearl_count += get_tree().get_nodes_in_group("owned_pearl").size()
	pearl_count += get_tree().get_nodes_in_group("unowned_pearl").size()
	$Counter/PearlCount/PanelContainer/HBoxContainer/Label.set_deferred("text", str(pearl_count))


func update_small_crab_count():
	var small_crab_count = get_tree().get_nodes_in_group("small_crab").size()
	$Counter/SmallCrabCount/PanelContainer/HBoxContainer/Label.set_deferred("text", str(small_crab_count))
	
	
func start_wave(wave: int):
	$StartWave/Label.text = "Wave " + str(wave)
	$StartWave/AnimationPlayer.play("start_wave")
	yield(get_tree().create_timer(3.0), "timeout")


func game_over():
	$AnimationPlayer.play("game_over")

func _on_BackToMenuButton_pressed():
	get_tree().change_scene("res://Menu.tscn")


func _on_RestartButton_pressed():
	get_tree().change_scene("res://Game.tscn")


func _on_ExitButton_pressed():
	get_tree().change_scene("res://Menu.tscn")
