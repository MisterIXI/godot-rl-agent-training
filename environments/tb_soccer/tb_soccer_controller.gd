extends AIController3D
class_name TBSoccerAIController

@export var env: TBSoccerEnv
@onready var turtle: TurtleBotController = get_parent()
@export var opponent: TurtleBotController
@export var ball: RigidBody3D
@export var own_goal: Area3D
@export var opponent_goal: Area3D

var running_rewards: Array[float] = [0]
var is_success: bool = false
var last_ball_pos: Vector3 = Vector3.ZERO

@export var disabled_agent: bool = false

func _ready():
	if not disabled_agent:
		super._ready()
	pass

func get_obs() -> Dictionary:
	var factor = env.settings.env_size.x
	var ball_pos = turtle.to_local(ball.global_position)
	var target_pos = turtle.to_local(opponent_goal.global_position)
	var opponent_pos = turtle.to_local(opponent.global_position)
	return {"obs": [
		turtle.position.x / factor,
		turtle.position.z / factor,
		opponent_pos.x / factor,
		opponent_pos.z / factor,
		target_pos.x / factor,
		target_pos.z / factor,
		ball_pos.x / factor,
		ball_pos.z / factor,
		ball.linear_velocity.x,
		ball.linear_velocity.z,
	]}

func get_reward() -> float:
	var result = reward
	# reward for ball getting closer to opponent goal
	var dist = ball.position.distance_to(opponent_goal.position)
	var diff = last_ball_pos.distance_to(opponent_goal.position) - dist
	# result scaled to field factor
	result += diff / env.settings.env_size.x * 50
	last_ball_pos = ball.position
	# code for running reward
	running_rewards.append(result)
	if running_rewards.size() > 60:
		running_rewards.pop_front()
	return result

func get_action_space() -> Dictionary:
	return {
		"twist_vel": {"size": 1, "action_type": "continuous"},
		"twist_ang": {"size": 1, "action_type": "continuous"},
	}

func set_action(action) -> void:
	turtle.set_twist_vel(action["twist_vel"][0])
	turtle.set_twist_ang(action["twist_ang"][0])


func _physics_process(_delta):
	n_steps += 1
	if n_steps > reset_after:
		needs_reset = true
		is_success = false
		done = true


func reset():
	n_steps = 0
	needs_reset = false
	turtle.twist_ang = 0
	turtle.twist_vel = 0
	last_ball_pos = ball.position
	running_rewards.clear()
	running_rewards.append(0)

func get_info() -> Dictionary:
	if done:
		return {
			"is_success": is_success,
		}
	return {}