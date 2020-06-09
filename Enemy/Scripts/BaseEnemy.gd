extends Node2D
class_name BaseEnemy
signal leave_map

enum { 
	STATE_IDLE,
	STATE_TARGETING,
	STATE_FLEEING,
	STATE_DIE,
	STATE_INIT,
	STATE_HOOK_RETURN,
	STATE_STUN,
	STATE_DIGGING,
	STATE_COMMING_OUT,
}

export var health: int
export var min_wave: int
export var difficulty_point: int
var state = STATE_IDLE
var target = null
var is_holding_pearl = false
var viewport: Viewport

func _ready():
	viewport = get_viewport()

func _process(delta):
	_process_state(state, delta)


func _process_state(_state, _delta: float):
	assert(false)

func receive_attack(_damage: int):
	pass

func destroy_pearl():
	for pearl in $PearlContainer.get_children():
		pearl.queue_free()
	
func leave_map():
	destroy_pearl()
	call_deferred("emit_signal", "leave_map")
	call_deferred("queue_free")
	
func die():
	queue_free()

func search_for_target():
	var target_pearl = null
	var min_distance = INF
	for pearl in get_tree().get_nodes_in_group("unowned_pearl"):
		var distance = global_position.distance_squared_to(pearl.global_position)
		if distance < min_distance:
			target_pearl = pearl
			min_distance = distance
	
	if target_pearl != null:
		return target_pearl
	else:
		return null
	
		
func pickup_target_pearl():
	assert(target != null)
	target.get_parent().remove_child(target)
	$PearlContainer.add_child(target)
	target.position = Vector2.ZERO
	if target.is_in_group("unowned_pearl"):
		target.remove_from_group("unowned_pearl")
	target.add_to_group("owned_pearl")
	is_holding_pearl = true

	
func drop_target_pearl():
	assert(target != null)
	if not is_instance_valid(target):
		return
		
	var prev_position = target.global_position
	$PearlContainer.remove_child(target)
	if target.is_in_group("owned_pearl"):
		target.remove_from_group("owned_pearl")	
	target.add_to_group("unowned_pearl")
	get_parent().add_child(target)
	target.global_position = prev_position
	is_holding_pearl = false

func simple_move(velocity: Vector2):
	var x = clamp(position.x + velocity.x, -INF, viewport.size.x)
	var y = clamp(position.y + velocity.y, 0.0, viewport.size.y)	
	position = Vector2(x, y)
	scale.x = sign(velocity.x) if velocity.x != 0.0 else 1.0
