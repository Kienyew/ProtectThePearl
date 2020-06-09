extends SimpleEnemy
class_name EnemyTank

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
		state = STATE_IDLE
		movement_speed = 0.0
		$AnimationPlayer.stop()
		$AnimationPlayer.play("receive_attack")
		$ReceiveAttackResetSpeedTimer.start()
	
func die():
	$Area2D.set_deferred("monitorable", false)
	$ReceiveAttackResetSpeedTimer.stop()
	$AnimationPlayer.play("die")
	state = STATE_DIE


func _on_ReceiveAttackResetSpeedTimer_timeout():
	movement_speed = base_movement_speed


func _on_VisibilityNotifier2D_screen_exited():
	if is_holding_pearl:
		leave_map()
		queue_free()
