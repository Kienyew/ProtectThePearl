extends KinematicBody2D
class_name Coconut

enum { STATE_IDLE, STATE_DROPPING, STATE_THROWING }

export var gravity = 98
export var base_drop_height: float
export var attack: float
export var penetration_power_left: int
var state = STATE_IDLE
var velocity: Vector2
var drop_distance_left: float

func _ready():
	$Area2D.monitoring = false
	

func _physics_process(delta):
	match state:
		STATE_THROWING:
			process_state_throwing(delta)
		STATE_DROPPING:
			process_state_dropping(delta)
			
func process_state_throwing(delta):
	var collision = move_and_collide(velocity * delta)
	if collision != null:
		velocity = velocity.bounce(collision.normal)
	
	rotation += deg2rad(60) * delta

func process_state_dropping(delta):
	if drop_distance_left > 0:
		var prev_position = position
		velocity.y += gravity * delta
		move_and_slide(velocity)
		var move_distance = position.distance_to(prev_position)
		drop_distance_left -= move_distance
		rotation_degrees += 90 * delta
	else:
		state = STATE_IDLE


func throw(_velocity: Vector2):
	$Area2D.monitoring = true
	state = STATE_THROWING
	velocity = _velocity

func start_dropping():
	position.x += rand_range(-50.0, 50.0)
	drop_distance_left = base_drop_height + rand_range(-50.0, 50.0)
	velocity = Vector2.ZERO
	state = STATE_DROPPING
	

func _on_Area2D_area_entered(area):
	if penetration_power_left <= 0:
		queue_free()
		return
			
	var attack_receiver = area.get_receiver()
	attack_receiver.receive_attack(attack)
	penetration_power_left -= 1


func _on_VisibilityNotifier2D_screen_exited():
	if state == STATE_THROWING:
		queue_free()
