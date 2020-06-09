extends BaseEnemy
class_name SimpleEnemy

export var base_movement_speed = 100
export var activation_x = 0.0
var movement_speed: float
var idle_target_position = null

func _ready():
	._ready()
	movement_speed = base_movement_speed

func receive_attack(damage: int):
	if is_holding_pearl:
		drop_target_pearl()
		
	health -= damage
	if health <= 0:
		die()
	else:
		$AnimationPlayer.play("receive_attack")
		state = STATE_FLEEING
		$ReceiveAttackFleeTimer.start()

func _process_state(state, delta):
	match state:
		STATE_IDLE:
			process_state_idle(delta)
			
		STATE_TARGETING:
			process_state_targeting(delta)
					
		STATE_FLEEING:
			process_state_fleeing(delta)
			
		STATE_DIE:
			process_state_die(delta)
		
			
			
func process_state_idle(delta):
	if $SearchTargetTimer.time_left == 0.0:
		var _target = search_for_target()
		if _target != null:
			target = _target
			state = STATE_TARGETING
		$SearchTargetTimer.start()
	else:
		if idle_target_position == null:
			var delta_position = Vector2.RIGHT * rand_range(25.0, 50.0)
			delta_position = delta_position.rotated(rand_range(0, TAU))
			idle_target_position = position + delta_position
			idle_target_position.x = clamp(idle_target_position.x, 25.0, viewport.size.x - 25.0)
			idle_target_position.y = clamp(idle_target_position.y, 25.0, viewport.size.y - 25.0)
		
		if position.distance_to(idle_target_position) <= 5.0:
			idle_target_position = null
		else:
			var velocity = (idle_target_position - position).normalized()
			velocity *= movement_speed * delta * 0.25
			simple_move(velocity)
			
		
func process_state_targeting(delta):
	if target.is_in_group("unowned_pearl"):
		var velocity
		if target.global_position.x < activation_x or global_position.x  > activation_x:
			velocity = (target.global_position - global_position).normalized()
			velocity *= movement_speed * delta
		else:
			velocity = Vector2.RIGHT * movement_speed * delta
			
		simple_move(velocity)
		
		if global_position.distance_to(target.global_position) < 15:
			pickup_target_pearl()
			state = STATE_FLEEING
	else:
		state = STATE_IDLE
		
func process_state_fleeing(delta):
	var velocity = Vector2.LEFT * movement_speed * delta * 1.2
	simple_move(velocity)


func process_state_die(_delta):
	pass

func die():
	$Area2D.set_deferred("monitorable", false)
	$ReceiveAttackFleeTimer.stop()
	state = STATE_DIE
	$AnimationPlayer.play("die")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"die":
			queue_free()

func _on_ReceiveAttackFleeTimer_timeout():
	state = STATE_IDLE


func _on_VisibilityNotifier2D_screen_exited():
	if state == STATE_DIE:
		return
		
	if is_holding_pearl:
		leave_map()
