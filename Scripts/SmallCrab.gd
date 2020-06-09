extends Node2D

enum { STATE_IDLE, STATE_TARGETING, STATE_RESTING }

export var target_radius: float 
export var movement_speed: float
export var attack: int
export var attack_radius: float
var target = null
var state = STATE_IDLE
var idle_target_position = null
var viewport

func _ready():
	viewport = get_viewport()

func _process(delta):
	match state:
		STATE_IDLE:
			process_state_idle(delta)
		STATE_TARGETING:
			process_state_targeting(delta)
		STATE_RESTING:
			process_state_resting(delta)
			
			
func process_state_idle(delta):
	if $SearchTargetTimer.time_left == 0.0:
		var enemy = search_for_target()
		if enemy != null:
			target = enemy
			state = STATE_TARGETING
		$SearchTargetTimer.start()
	else:
		if idle_target_position == null:
			var delta_pos = Vector2.RIGHT * 100.0
			delta_pos = delta_pos.rotated(rand_range(0.0, TAU))
			idle_target_position = position + delta_pos
			idle_target_position.x = clamp(idle_target_position.x, 25.0, viewport.size.x - 25.0)
			idle_target_position.y = clamp(idle_target_position.y, 25.0, viewport.size.y - 25.0)
		
		var velocity = global_position.direction_to(idle_target_position)
		velocity *= movement_speed * delta * 0.25
		move(velocity)
		if global_position.distance_to(idle_target_position) <= 15.0:
			idle_target_position = null
		
	
	
func process_state_targeting(delta):
	if not is_instance_valid(target) or not target.is_in_group("enemy"):
		target = null
		state = STATE_IDLE
		return	
	
	var direction = global_position.direction_to(target.global_position)
	var velocity = direction * movement_speed * delta
	move(velocity)
	
	if global_position.distance_to(target.global_position) <= attack_radius:
		target.receive_attack(attack)
		state = STATE_RESTING
		target = null


func process_state_resting(_delta):
	if $RestingTimer.time_left == 0.0:
		state = STATE_IDLE
		$RestingTimer.start()


func search_for_target() -> BaseEnemy:
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.empty():
		return null
	
	var enemies_in_radius = []
	for enemy in enemies:
		if global_position.distance_to(enemy.global_position) <= target_radius:
			enemies_in_radius.append(enemy)
	
	if enemies_in_radius.empty():
		return enemies[randi() % enemies.size()]
	else:
		return enemies_in_radius[randi() % enemies_in_radius.size()]


func move(velocity: Vector2):
	global_position += velocity
	rotation = atan2(velocity.y, velocity.x)
