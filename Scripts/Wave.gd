extends Node

signal wave_clear

var game: Node
var enemy_scenes: Array
var wave_running: bool = false
var enemy_clear: bool = true
var game_over: bool = false

func _ready():
	game = find_parent("Game")
	enemy_scenes = game.enemy_scenes

func _process(_delta):
	if game_over:
		return
		
	if not wave_running and not enemy_clear and get_tree().get_nodes_in_group("enemy").size() == 0:
		enemy_clear = true
		emit_signal("wave_clear")

func start_wave(wave: int):
	wave_running = true
	enemy_clear = false
	var difficulty_point_left = wave * wave
	var good_enemy_scenes = self.enemy_scenes.duplicate()
	while not game_over and difficulty_point_left > 0 and good_enemy_scenes.size() > 0:
		var enemy_scene = good_enemy_scenes[randi() % good_enemy_scenes.size()]
		var enemy = enemy_scene.instance()
		var can_spawn = difficulty_point_left >= enemy.difficulty_point and wave >= enemy.min_wave
		if can_spawn:
			difficulty_point_left -= enemy.difficulty_point
			yield(get_tree().create_timer(rand_range(1.0/wave, 2.0/wave)), "timeout")
			game.spawn_enemy(enemy)
		else:
			good_enemy_scenes.remove(good_enemy_scenes.find(enemy_scene))
	
	wave_running = false


func _on_Game_game_over():
	game_over = true
