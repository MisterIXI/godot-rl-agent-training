extends AIController3D
class_name TargetDrivingAIController

@onready var turtle: TurtleBotController = get_parent()
@onready var env: TargetDrivingEnv = get_parent().get_parent()
@export var info_label: Label3D
@export var raycast_sens: RayCastSensor3D
@export var lidar_sens: RayCastSensor3D
@export var ultrasonic_sens: RayCast3D

var running_rewards: Array[float] = []
var is_success: bool = false

const FOV = 120.0
const BALL_MIDDLE = 20.0

var turns_made: int = 0
var angle_accum: float = 0

func _ready():
	super._ready()
	lidar_sens.display()
	raycast_sens.display()	
	# turtle.body_entered.connect(_on_turtle_body_entered)

func get_obs() -> Dictionary:
	var target_pos = turtle.to_local(env.target.global_position)
	var lidar_scan = lidar_sens.get_observation()

	var factor = env.settings.env_size.x


	var obs_arr = [
		target_pos.x / factor,
		target_pos.z / factor,
	]
	obs_arr.append_array(lidar_scan)
	return {
		"obs": obs_arr
	}

func get_reward() -> float:
	var result = reward
	# mini punish for driving backwards
	if turtle.twist_vel < 0:
		result -= 0.1
	# mini punishment for turning to discourage
	result -= turns_made * 0.1
	turns_made = 0
		# code for info label
	running_rewards.append(result)
	if running_rewards.size() > 60:
		running_rewards.pop_front()
	var sum = running_rewards.reduce(func(acc, x): return acc + x, 0) / 60
	var text = "Reward: " + str("%+.2f" % result) + " Avg: " + str("%+.2f" % sum)
	text += "\nGoals/min: " + "%.2f" % (env.goals_reached.size() / 5.0)
	info_label.text = text
	return result

func get_action_space() -> Dictionary:
	return {
		"twist_vel": {"size": 1, "action_type": "continuous"},
		"twist_ang": {"size": 1, "action_type": "continuous"},
	}

func set_action(action) -> void:
	turtle.set_twist_vel(clamp(action["twist_vel"][0], -0.5, 1.0))
	# turtle.set_twist_vel(-action["twist_vel"][0])
	turtle.set_twist_ang(action["twist_ang"][0])

func _physics_process(_delta):
	get_obs()
	# spiral calc
	angle_accum += turtle.twist_ang * _delta
	if abs(angle_accum) > deg_to_rad(360):
		turns_made += 1
		if angle_accum < 0:
			angle_accum += deg_to_rad(360)
		else:
			angle_accum -= deg_to_rad(360)
	
	n_steps += 1
	if n_steps > reset_after:
		# print("N_steps: ", n_steps)
		needs_reset = true
		is_success = false
		done = true
		# reward += env.settings.reward_failure
	if needs_reset:
		# print("Needs_reset: ", needs_reset)
		env.reset()

func reset():
	n_steps = 0
	needs_reset = false
	turtle.twist_ang = 0
	turtle.twist_vel = 0
	turns_made = 0
	angle_accum = 0
	pass

func get_info() -> Dictionary:
	if done:
		return {
			"is_success": is_success,
		}
	return {}



func _on_target_area_body_entered(body:Node3D) -> void:
	if body == turtle:
		env.target_reached()

func _on_turtlebot_body_entered(body:Node) -> void:
	if body.is_in_group("Wall"):
		needs_reset = true
		done = true
		is_success = false
		reward += env.settings.reward_failure
