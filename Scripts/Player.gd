extends Node2D

export var claw_attack_scene: PackedScene
export var movement_speed = 200
export var rotation_speed = 120
export var attack_cooldown = 0.5
export var throw_coconut_force: float
export var distance_reach_coconut: float
export var allow_offscreen: bool
export var attack: int
export var penetration_power: int
var attack_cooldown_ok = true
var viewport: Viewport
var is_holding_coconut = false

func _ready():
	viewport = get_viewport()

func _process(delta):
	if Input.is_action_pressed("move_left"):
		var velocity = Vector2(cos(deg2rad(rotation_degrees + 145)),
							   sin(deg2rad(rotation_degrees + 145)))
		
		velocity *= movement_speed * delta
		move(velocity)

	elif Input.is_action_pressed("move_right"):
		var velocity = Vector2(cos(deg2rad(rotation_degrees + 215)),
							   sin(deg2rad(rotation_degrees + 215)))
		
		velocity *= movement_speed * delta
		move(velocity)
		
	if Input.is_action_pressed("rotate_left"):
		rotate(deg2rad(rotation_speed * delta))
	if Input.is_action_pressed("rotate_right"):
		rotate(deg2rad(-rotation_speed * delta))
	
	if Input.is_action_pressed("pickup"):
		if not is_holding_coconut:
			pickup_coconut()
	
	if Input.is_action_pressed("attack"):
		if is_holding_coconut:
			throw_coconut()
		elif attack_cooldown_ok:
			attack()

func move(velocity: Vector2):
	var x
	var y
	
	if not allow_offscreen:
		x = clamp(position.x + velocity.x, 0.0, viewport.size.x)
		y = clamp(position.y + velocity.y, 0.0, viewport.size.y)
	else:
		x = position.x + velocity.x
		y = position.y + velocity.y
		
	position = Vector2(x, y)


func attack():
	attack_cooldown_ok = false
	var claw = claw_attack_scene.instance()
	claw.penetration_power_left = penetration_power
	claw.attack = attack
	if randi() % 2 == 0:
		$ClawAttackPositionLeft.add_child(claw)
	else:
		$ClawAttackPositionRight.add_child(claw)
		
	claw.get_node("AnimationPlayer").play("attack")
	yield(get_tree().create_timer(self.attack_cooldown), "timeout")
	attack_cooldown_ok = true

func pickup_coconut() -> bool:
	var coconuts = get_tree().get_nodes_in_group("coconut")
	var nearest_coconut = null
	var nearest_distance = INF
	for coconut in coconuts:
		if coconut.state != Coconut.STATE_IDLE:
			continue
			
		var distance = global_position.distance_squared_to(coconut.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_coconut = coconut
	
	if nearest_coconut != null and global_position.distance_to(nearest_coconut.global_position) <= distance_reach_coconut:
		is_holding_coconut = true
		nearest_coconut.get_parent().remove_child(nearest_coconut)
		$CoconutContainer.add_child(nearest_coconut)
		nearest_coconut.position = Vector2.ZERO
		return true
	else:
		return false		
	
func throw_coconut():
	assert(is_holding_coconut)
	var coconut = $CoconutContainer.get_child(0)
	var front = rotation + PI
	var velocity = Vector2(cos(front), sin(front)) * throw_coconut_force
	var prev_pos = coconut.global_position
	$CoconutContainer.remove_child(coconut)
	get_parent().add_child(coconut)
	coconut.global_position = prev_pos
	coconut.throw(velocity)
	is_holding_coconut = false
