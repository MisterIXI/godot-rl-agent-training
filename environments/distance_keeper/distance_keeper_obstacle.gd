extends CharacterBody3D
class_name ObstacleMovement
var time_left = 0.0
var current_input = 0.0
@export var distance_agent: DistanceKeeperAgent
@onready var env: DistanceKeeperEnv = get_parent()

func _physics_process(delta):
	time_left -= delta
	if time_left <= 0:
		time_left = randf_range(0.5, 2.0)
		current_input = randf_range(-1.0, 1.0)
	var dist = current_input * env.settings.max_obstacle_speed * delta

	dist = clamp(dist, -env.settings.env_size.x / 2 - position.x + 3.0, env.settings.env_size.x / 2 - position.x - 0.5)
	move_and_collide(Vector3.RIGHT * dist)