extends Node2D

export var game_scene: PackedScene

var messages = [
	"This is intro",
	"Those ugly monstrous creatures are having some ugly intention on the precious shiny pearls on your owned beach",
	"This is unbearable!",
	"Arm with your arm and defeat those ugly monstrous creatures!",
	"Beware, they might have some unexpected skill",
	"Such a bad things to hear such skillful creatures are theives!",
	"Now, move your legs and departs to the beach",
	"...",
	"Just try [WASD] or the [Arrow Keys] as always",
	"Hard to control?",
	"Crustacean's life is that hard",
	"Press [Space] to use your powerful claw to hit those ugly monstrous creatures",
	"...",
	"See that coconut?",
	"Get close to it and press [E] to pick it up",
	"Unfortunately, you are not coconut crab so you don't eat that",
	"Press [Space] to throw it away",
	"...",
	"So what is the point, coconut?",
	"...",
	"Let's see",
	"Now, heads to the stage",
	"...",
	"Move out the screen for letting the Visibility Notifier works",	
]

var current_message_index = 0
var back_to_menu_flag = false

func _ready():
	$Player.allow_offscreen = true
	update_label()
		

func update_label():
	$Label.text = messages[current_message_index]
	

func _on_NextButton_pressed():
	current_message_index += 1
		
	if current_message_index >= messages.size():
		current_message_index = messages.size() - 1
		
		
	update_label()


func _on_PrevButton_pressed():
	current_message_index -= 1
	if current_message_index <= 0:
		back_to_menu_flag = true
		get_tree().change_scene("res://Menu.tscn")
		
	update_label()


func _on_VisibilityNotifier2D_screen_exited():
	if back_to_menu_flag:
		return
		
	get_tree().change_scene_to(game_scene)	
	
