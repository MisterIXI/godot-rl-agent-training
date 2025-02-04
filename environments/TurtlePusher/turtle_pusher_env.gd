extends Node3D
class_name TurtlePusherEnv

@export var settings: TurtlePusherEnvSettings
@export var turtle: TurtleBotController
@export var tb_ai_controller: TBPushAIController
@export var ball: RigidBody3D
@export var target: Area3D

var goals_reached: Array[int] = []

func roll_random_pos(half_size: float) -> Vector3:
	return Vector3(
		randf_range(-half_size, half_size),
		0,
		randf_range(-half_size, half_size)
	)

func _physics_process(_delta):
	# if goals_reached first entry is older than 60 seconds, remove it
	if goals_reached.size() > 0 and Time.get_ticks_msec() - goals_reached[0] > 60000 * 5:
		goals_reached.pop_front()
		
	# check if turtle is OOB:
	var bounds_x = settings.env_size.x / 2 -0.15
	if (
		turtle.position.x < -bounds_x or
		turtle.position.x > bounds_x or
		turtle.position.z < -bounds_x or
		turtle.position.z > bounds_x
	):
		# tb_ai_controller.reward += settings.reward_failure
		tb_ai_controller.done = true
		tb_ai_controller.needs_reset = true
		tb_ai_controller.is_success = false
	# check if ball is OOB:
	if (
		ball.position.x < -bounds_x or
		ball.position.x > bounds_x or
		ball.position.z < -bounds_x or
		ball.position.z > bounds_x
	):
		# tb_ai_controller.reward += settings.reward_failure
		tb_ai_controller.done = true
		tb_ai_controller.needs_reset = true
		tb_ai_controller.is_success = false

func reset() -> void:
	# roll positions until all are valid
	var turtle_pos: Vector3 = Vector3.ZERO
	var ball_pos: Vector3 = Vector3.ZERO
	var target_pos: Vector3 = Vector3.ZERO
	var half_env_size: float = settings.env_size.x / 2 - settings.spawn_margin * 2
	# random turtle pos
	turtle_pos = roll_random_pos(half_env_size)
	turtle.position = turtle_pos
	# random turtle rotation
	turtle.rotation_degrees.y = randf_range(0, 360)
	# random ball pos
	ball_pos = roll_random_pos(half_env_size)
	while ball_pos.distance_to(turtle_pos) < settings.spawn_margin * 2:
		ball_pos = roll_random_pos(half_env_size)
	ball_pos.y = 0.1
	ball.position = ball_pos
	# random target pos
	target_pos = roll_random_pos(half_env_size)
	while (
		target_pos.distance_to(turtle_pos) < settings.spawn_margin * 2 or
		target_pos.distance_to(ball_pos) < settings.spawn_margin * 2
	):
		target_pos = roll_random_pos(half_env_size)
	target.position = target_pos
	# stop ball velocities
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	# reset ai controller
	tb_ai_controller.reset()
	pass


func _on_target_area_body_entered(body:Node3D) -> void:
	if body.is_in_group("Ball"):
		tb_ai_controller.reward += settings.reward_success
		tb_ai_controller.done = true
		tb_ai_controller.needs_reset = true
		tb_ai_controller.is_success = true
		goals_reached.append(Time.get_ticks_msec())


