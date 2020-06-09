extends BaseEnemy

export var activation_x: float
export var base_movement_speed = 75.0
export var hook_out_speed = 250.0
export var hook_return_speed_with_pearl = 250.0
export var hook_return_speed_no_pearl = 1000.0
var movement_speed
var is_hooking_pearl = false

func _ready():
	._ready()
	movement_speed = base_movement_speed
	state = STATE_INIT

func _process_state(_state, delta: float):
	match _state:
		STATE_INIT:
			process_state_init(delta)
		STATE_IDLE:
			process_state_idle(delta)
		STATE_TARGETING:
			process_state_targeting(delta)
		STATE_HOOK_RETURN:
			process_state_hook_return(delta)
		STATE_FLEEING:
			process_state_fleeing(delta)
		STATE_STUN:
			process_state_stun(delta)
		STATE_DIE:
			process_state_die(delta)


func process_state_init(delta):
	var velocity = Vector2.RIGHT * movement_speed * delta
	simple_move(velocity)
	if position.x >= activation_x:
		state = STATE_IDLE
	
func process_state_idle(_delta):
	if $SearchTargetTimer.time_left == 0.0:
		var _target = search_for_target()
		if _target != null:
			target = _target
			state = STATE_TARGETING
			
		$SearchTargetTimer.start()
	
func process_state_targeting(delta):
	if not target.is_in_group("unowned_pearl"):
		state = STATE_HOOK_RETURN
		return
		
	if target.global_position.x < global_position.x:
		self.scale.x = -1.0
	else:
		self.scale.x = 1.0
	
	var point = $HookStart/Line2D.global_position + $HookStart/Line2D.get_point_position(1)
	var velocity = (target.global_position - point).normalized()
	velocity *= hook_out_speed * delta
	point += velocity
	$HookStart/Line2D.set_point_position(1, point - $HookStart/Line2D.global_position)
	$HookPearlContainer.global_position = point
	if point.distance_to(target.global_position) <= 15.0:
		hook_target()
		state = STATE_HOOK_RETURN
	
func process_state_hook_return(delta):
	var point = $HookStart/Line2D.get_point_position(1)
	var velocity = (-point).normalized()
	velocity *= hook_return_speed_with_pearl if is_hooking_pearl else hook_return_speed_no_pearl
	velocity *= delta
	point += velocity
	$HookStart/Line2D.set_point_position(1, point)
	$HookPearlContainer.position = $HookStart.position + point
	if $HookPearlContainer.position.distance_to($HookStart.position) <= 15.0:
		if is_hooking_pearl:
			pickup_target_pearl()
			is_hooking_pearl = false
			state = STATE_FLEEING
		else:
			state = STATE_IDLE
		$HookStart/Line2D.set_point_position(1, Vector2.ZERO)
	
func process_state_fleeing(delta):
	var velocity = Vector2.LEFT * movement_speed * delta
	simple_move(velocity)

func process_state_stun(_delta):
	pass

func process_state_die(_delta):
	pass

func receive_attack(damage: int):
	if is_holding_pearl:
		drop_target_pearl()
		
	if is_hooking_pearl:
		drop_hooking_pearl()
		
	health -= damage
	if health <= 0:
		state = STATE_DIE
		die()
	else:
		$AnimationPlayer.stop()
		$AnimationPlayer.play("receive_attack")
		match state:
			STATE_TARGETING:
				state = STATE_HOOK_RETURN
			STATE_HOOK_RETURN:
				pass
			_:
				$StunTimer.start()
				state = STATE_STUN
				
	
func die():
	$Area2D.set_deferred("monitorable", false)
	$HookStart/Line2D.clear_points()
	$AnimationPlayer.play("die")

func hook_target():
	assert(target != null)
	target.get_parent().remove_child(target)
	$HookPearlContainer.add_child(target)
	target.remove_from_group("unowned_pearl")
	target.add_to_group("owned_pearl")
	target.position = Vector2.ZERO
	is_hooking_pearl = true

func drop_hooking_pearl():
	assert(is_hooking_pearl)
	var prev_position = target.global_position
	$HookPearlContainer.remove_child(target)
	get_parent().add_child(target)
	target.global_position = prev_position
	target.remove_from_group("owned_pearl")
	target.add_to_group("unowned_pearl")
	is_hooking_pearl = false

func _on_VisibilityNotifier2D_screen_exited():
	if state == STATE_DIE:
		return
		
	if is_holding_pearl:
		leave_map()


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"die":
			queue_free()


func _on_StunTimer_timeout():
	if state == STATE_DIE:
		return
	state = STATE_IDLE
