extends AnimatedSprite
var flooding = false
func flood():
	flooding = true
	$AnimationPlayer.play("flood")
	var pearls_on_ground = get_tree().get_nodes_in_group("unowned_pearl")
	while flooding:
		var pickup_pearls = []
		for pearl in pearls_on_ground:
			if $Peak.global_position.x <= pearl.global_position.x:
				var prev_position  = pearl.global_position
				pearl.get_parent().remove_child(pearl)
				$PearlContainer.add_child(pearl)
				pickup_pearls.append(pearl)
				var x = $Peak.global_position.x
				var y = prev_position.y
				pearl.global_position = Vector2(x, y)
		
		for pearl in pickup_pearls:
			pearls_on_ground.remove(pearls_on_ground.find(pearl))
		
		for pearl in $PearlContainer.get_children():
			pearl.global_position.x = $Peak.global_position.x + rand_range(-25.0, 25.0)
		
		yield(get_tree().create_timer(0.1), "timeout")
	
	for pearl in $PearlContainer.get_children():
		var prev_position = pearl.global_position
		$PearlContainer.remove_child(pearl)
		get_parent().add_child(pearl)
		pearl.global_position = prev_position
				
		
func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"flood":
			flooding = false
