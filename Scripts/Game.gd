extends Node2D
class_name Game	

signal game_over

export(PackedScene) var pearl_scene
export(Array, PackedScene) var enemy_scenes
export(PackedScene) var small_crab_scene

export var wave = 1
var viewport: Viewport

func _ready():
	randomize()
	viewport = get_viewport()
	enemy_scenes.sort_custom(self, "_sort_difficulty_point")
	spawn_pearl(3)
	
	
func _sort_difficulty_point(a, b):
	return a.instance().difficulty_point < b.instance().difficulty_point


func spawn_enemy(enemy):
	$Enemies.add_child(enemy)
	enemy.position = Vector2(-50.0, rand_range(25.0, get_viewport_rect().size.y - 25.0))
	enemy.connect("leave_map", self, "_on_enemy_leave_map")
	

func spawn_pearl(count: int):
	for _i in range(count):
		var x = $PearlContainer.position.x + rand_range(-25.0, 25.0)
		var y = rand_range(25.0, get_viewport_rect().size.y - 25.0)
		var pearl = pearl_scene.instance()
		$PearlContainer.add_child(pearl)
		pearl.global_position = Vector2(x, y)
		
	$HUD.update_pearl_count()
		

func spawn_small_crab(count: int):
	for _i in range(count):
		var x = rand_range(100.0, viewport.size.x - 100.0)
		var y = rand_range(100.0, viewport.size.y - 100.0)
		var small_crab = small_crab_scene.instance()
		add_child(small_crab)
		small_crab.position = Vector2(x, y)
		
	$HUD.update_small_crab_count()


func _on_NextWaveCounter_timeout():
	$HUD.start_wave(wave)
	yield(get_tree().create_timer(2.0), "timeout")
	$Wave.start_wave(wave)


func _on_Wave_wave_clear():
	wave += 1
	$Wave/NextWaveCounter.start()
	spawn_pearl(1)
	spawn_small_crab(int(wave / 6))
	$Flood.flood()
	
	if wave > Global.best_wave:
		Global.best_wave = wave


func game_over():
	$Wave/SpawnEnemyTimer.stop()
	$Wave/NextWaveCounter.stop()
	emit_signal("game_over")
	$HUD.game_over()
	

func _on_enemy_leave_map():
	$HUD.update_pearl_count()
	var pearl_count = 0
	pearl_count += get_tree().get_nodes_in_group("owned_pearl").size()
	pearl_count += get_tree().get_nodes_in_group("unowned_pearl").size()
	if pearl_count <= 0:
		game_over()
