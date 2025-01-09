extends AIController3D
class_name TBPushAIController

@onready var turtle: TurtleBotController = get_parent()
@onready var env: TurtlePusherEnv = get_parent().get_parent()

var is_success: bool = false

# func _ready():
# 	pass

func get_obs() -> Dictionary:
	var factor = env.settings.env_size.x / 2
	return {"obs": [
		turtle.position.x / factor,
		turtle.position.z / factor,
		env.target.position.x / factor,
		env.target.position.z / factor,
		env.ball.position.x / factor,
		env.ball.position.z / factor,
		env.ball.linear_velocity.x,
		env.ball.linear_velocity.z,
	]}


func get_reward() -> float:
	var result = reward
	# TODO: Add actual reward logic
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
		# print("N_steps: ", n_steps)
		needs_reset = true
		is_success = false
		done = true
		reward += env.settings.reward_failure
	if needs_reset:
		# print("Needs_reset: ", needs_reset)
		env.reset()

func reset():
	n_steps = 0
	needs_reset = false
	pass

func get_info() -> Dictionary:
	if done:
		return {
			"is_success": is_success,
		}
	return {}