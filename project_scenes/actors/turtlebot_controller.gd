extends RigidBody3D
class_name TurtleBotController

@export var manual_control_override = false
## simulated twist velocity for backward/forward (-0.20 to 0.20) (theoretical max -0.22 to 0.22)
var twist_vel = 0.0
## simulated twist angle for backward/forward (-2 to 2) (theoretical max -2.84 to 2.84)
var twist_ang = 0.0
## target velocity which the twist_vel will move towards with the rate of TWIST_VEL_RATE
var target_vel = 0.0
## target angle which the twist_ang will move towards with the rate of TWIST_ANG_RATE
var target_ang = 0.0
@export var wheel_left: Node3D
@export var wheel_right: Node3D
const TURTLEBOT_MASS = 500

const TWIST_ANG_RATE = 2.5
const TWIST_VEL_RATE = 0.5
	
	
func _physics_process(delta: float) -> void:
	if manual_control_override:
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		# input_dir = input_dir.normalized()
		target_vel = -input_dir.y * 0.20
		target_ang = -input_dir.x * 2.0
	# move towards target velocity
	twist_vel = move_toward(twist_vel, target_vel, TWIST_VEL_RATE * delta)
	# move towards target angle
	twist_ang = move_toward(twist_ang, target_ang, TWIST_ANG_RATE * delta)
	# calculate velocity
	var velocity = Vector3.ZERO
	velocity.z = -twist_vel
	velocity = transform.basis * velocity
	rotate_y(twist_ang * delta)	
	var wheel_rot_speed := Vector2.ZERO
	# animate wheels
	# twist_vel animation part
	wheel_rot_speed += -(twist_vel * 5) * Vector2.ONE * deg_to_rad(360)
	# twist_ang animation part
	wheel_rot_speed += (Vector2(twist_ang, -twist_ang) * 0.5) * deg_to_rad(360)
	# rotate wheels according to wheel_rot_speed
	wheel_left.rotate_x(wheel_rot_speed.x * delta)
	wheel_right.rotate_x(wheel_rot_speed.y * delta)
	# adjust linear velocity to match desired velocity
	linear_velocity = linear_velocity.move_toward(velocity, 0.5)

## Set the twist velocity 
## [param vel]: float - the twist velocity to set in -1 to 1 range (automatically reduces to the turtlebot speed of -0.20 to 0.20)
func set_twist_vel(vel: float) -> void:
	target_vel = vel * 0.20

## Set the twist angle
## [param ang]: float - the twist angle to set in -1 to 1 range (automatically reduces to the turtlebot speed of -2 to 2)
func set_twist_ang(ang: float) -> void:
	target_ang = ang * 2.0