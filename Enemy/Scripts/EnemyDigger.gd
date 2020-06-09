extends BaseEnemy
class_name EnemyDigger

export var digging_speed: float
export var movement_speed: float
export var activation_x: float
var idle_target_position = null


func _ready():
	._ready()
	state = STATE_DIGGING
	

func _process_state(_state, delta):
	match _state:
		STATE_IDLE:
			process_state_idle(delta)
		STATE_DIGGING:
			process_state_digging(delta)
		STATE_COMMING_OUT:
			process_state_coming_out(delta)
		STATE_TARGETING:
			process_state_targeting(delta)
		STATE_FLEEING:
			process_state_fleeing(delta)

func process_state_idle(delta):
	if $SearchTargetTimer.time_left == 0:
		$SearchTargetTimer.start()
		var _target = search_for_target()
		if _target != null:
			target = _target
			state = STATE_TARGETING
	else:
		if idle_target_position == null:
			var angle = rand_range(0.0, TAU)
			var radius = rand_range(25.0, 50.0)
			var delta_position = Vector2(cos(angle), sin(angle)) * radius
			idle_target_position = position + delta_position
		
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

func process_state_digging(delta):
	var velocity = Vector2.RIGHT * digging_speed * delta
	simple_move(velocity)
	if position.x >= activation_x:
		state = STATE_COMMING_OUT


func process_state_fleeing(delta):
	var velocity = Vector2.LEFT * movement_speed * delta
	simple_move(velocity)


func process_state_coming_out(_delta):
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("comming_out")


func receive_attack(damage: int):
	if state in [STATE_DIGGING, STATE_COMMING_OUT]:
		return
	
	if is_holding_pearl:
		drop_target_pearl()
	
	health -= damage
	if health <= 0:
		state = STATE_DIE
		die()
	else:
		$AnimationPlayer.stop()
		$AnimationPlayer.play("receive_attack")
		if $StunTimer.time_left == 0.0:
			state = STATE_STUN
			$StunTimer.start()
		
	

func die():
	$Area2D.set_deferred("monitorable", false)
	$AnimationPlayer.play("die")


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"comming_out":
			state = STATE_IDLE
			$Area2D.monitorable = true
			$Particles2D.emitting = false
		"die":
			queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	if state == STATE_DIE:
		return
		
	leave_map()


func _on_StunTimer_timeout():
	if state == STATE_DIE:
		return
		
	state = STATE_IDLE
