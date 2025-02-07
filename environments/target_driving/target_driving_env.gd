extends Node3D
class_name TargetDrivingEnv



@export var settings: TargetDrivingEnvSetting
@export var turtle: TurtleBotController
@export var tb_ai_controller: TargetDrivingAIController
@export var target: Area3D

var target_reached_count = 0
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


func target_reached() -> void:
	target_reached_count += 1
	tb_ai_controller.reward += settings.reward_success
	goals_reached.append(Time.get_ticks_msec())
	reposition_target_area()
	if target_reached_count >= 5:
		tb_ai_controller.done = true
		tb_ai_controller.needs_reset = true
		tb_ai_controller.is_success = true

func reposition_target_area() -> void:
	var half_env_size: float = settings.env_size.x / 2 - settings.spawn_margin * 2
	var new_pos: Vector3 = roll_random_pos(half_env_size)
	while (
		new_pos.distance_to(turtle.position) < settings.spawn_margin * 2
	):
		new_pos = roll_random_pos(half_env_size)
	target.position = new_pos

func reset() -> void:
	# roll positions until all are valid
	var turtle_pos: Vector3 = Vector3.ZERO
	var target_pos: Vector3 = Vector3.ZERO
	var half_env_size: float = settings.env_size.x / 2 - settings.spawn_margin * 2
	# random turtle pos
	turtle_pos = roll_random_pos(half_env_size)
	turtle.position = turtle_pos
	# random turtle rotation
	turtle.rotation_degrees.y = randf_range(0, 360)
	# random target pos
	target_pos = roll_random_pos(half_env_size)
	while (
		target_pos.distance_to(turtle_pos) < settings.spawn_margin * 2
	):
		target_pos = roll_random_pos(half_env_size)
	target.position = target_pos
	target_reached_count = 0
	# reset ai controller
	tb_ai_controller.reset()
	pass


