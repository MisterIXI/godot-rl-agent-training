extends AIController3D
class_name TBPushAIController
@onready var turtle: TurtleBotController = get_parent()
@onready var env: TurtlePusherEnv = get_parent().get_parent()
@export var info_label: Label3D
@export var raycast_sens: RayCastSensor3D
@export var lidar_sens: RayCastSensor3D

var running_rewards: Array[float] = []
var is_success: bool = false
var last_closest_dist_change: int = 0
var closest_dist: float = 0
var closest_to_ball: float = 0
var ball_in_button_area: bool = false
var has_been_close_to_ball: bool = false

var turns_made: int = 0
var angle_accum: float = 0

func _ready():
	super._ready()
	lidar_sens.display()
	raycast_sens.display()	

func locate_ball(sens_arr):
	var fov = 120
	var hits = []
	var step = fov / (sens_arr.size() / 2.0)
	var curr = - fov / 2.0
	for i in range(sens_arr.size() / 2):
		if sens_arr[(i*2+1)] == 1:
			hits.append(curr)
		curr += step
	var accum = 0.0
	for num in hits:
		accum += num
	accum *= -1.0
	if hits.size() > 0:
		return accum / hits.size()
	else:
		return null



func get_obs() -> Dictionary:
	var ball_angle = locate_ball(raycast_sens.get_observation())
	var sees_ball = 1.0
	if ball_angle == null:
		sees_ball = 0.0
		ball_angle = 0.0
	var lidar_scan = lidar_sens.get_observation()

	
	# print("0: " + str(lidar_scan[0]) + " | 89: " + str(lidar_scan[89]))
	# print(lidar_buckets)
	# for i in range(sens.size()):
	# 	sens[i] = 1 if sens[i] > 0 else 0
	var factor = env.settings.env_size.x
	# var ball_pos = turtle.to_local(env.ball.global_position)
	var target_pos = turtle.to_local(env.target.global_position)
	# ball vel in turtle local space, scaled by 10 to be roughly -1 to 1
	# var ball_vel = turtle.to_local(env.ball.linear_velocity + turtle.global_position)
	var obs_arr = [
		# turtle.position.x / factor,
		# turtle.position.z / factor,
		target_pos.x / factor,
		target_pos.z / factor,
		ball_angle / 60.0,
		sees_ball,
		# ball_pos.x / factor,
		# ball_pos.z / factor,
	]
	# obs_arr.append_array(sens)
	obs_arr.append_array(lidar_scan)
	return {"obs": obs_arr}


func get_reward() -> float:
	var result = reward
	# mini punishment for turning to discourage
	result -= turns_made * 0.1
	turns_made = 0
	# check if ball is now closer to target than record of run
	var dist = env.ball.position.distance_to(env.target.position)
	if dist < closest_dist:
		var dif = (closest_dist - dist) / 4.0
		result += dif * 100
		closest_dist = dist
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
	turtle.set_twist_vel(clamp(action["twist_vel"][0], -1.0, 0.5))
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
	closest_dist = env.ball.position.distance_to(env.target.position)
	closest_to_ball = env.ball.position.distance_to(env.turtle.position)
	has_been_close_to_ball = false
	turns_made = 0
	angle_accum = 0
	pass

func get_info() -> Dictionary:
	if done:
		return {
			"is_success": is_success,
		}
	return {}


func _on_area_3d_body_entered(body: Node3D):
	if body.is_in_group("Ball"):
		ball_in_button_area = true

func _on_area_3d_body_exited(body: Node3D):
	if body.is_in_group("Ball"):
		ball_in_button_area = false
