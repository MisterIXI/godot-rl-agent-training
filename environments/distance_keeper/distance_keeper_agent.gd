extends CharacterBody3D
class_name DistanceKeeperAgent

@export var obstacle: CharacterBody3D
@export var ai_controller: DistanceAIController
@onready var env: DistanceKeeperEnv = get_parent()
## move input, -1 to 1 for left to right
var move_input = 0.0

## fake sensor output
var sensor_output = 0.0


func _ready():
	ai_controller.init(self, env)
	env.reset_env()

func calc_reward():
	# calc dist to obstacle, the closer to TARGET_DIST the better
	var dist = abs(obstacle.position.x - position.x)
	var reward = 0
	reward += (env.settings.target_dist - dist) * 0.1
	return reward

func _physics_process(delta):
	# -1 to account for half of both agent and obstacle size
	sensor_output = obstacle.position.x - position.x - 1.0
	# avoid overshooting of sensor (only with collision)
	sensor_output = max(0, sensor_output)
	var clamped_input = clamp(move_input, -1, 1)
	var dist = clamped_input * env.settings.max_agent_speed * delta
	dist = clamp(dist, -env.settings.env_size.x/2 - position.x, env.settings.env_size.x/2 - position.x)
	# move the agent
	var col = move_and_collide(Vector3.RIGHT * dist)
	if col:
		# check if we hit the obstacle
		if col.get_collider() == obstacle:
			ai_controller.needs_reset = true
			ai_controller.reward += env.settings.fixed_penalty
			ai_controller.done = true
			# reset the environment
			env.reset_env()


