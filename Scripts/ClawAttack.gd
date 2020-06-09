extends Area2D

export var attack = 3
export var penetration_power_left = 3

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()


func _on_ClawAttack_area_entered(area):
	if penetration_power_left <= 0:
		return
	
	var attack_receiver = area.get_receiver()
	penetration_power_left -= 1
	attack_receiver.receive_attack(attack)
		
