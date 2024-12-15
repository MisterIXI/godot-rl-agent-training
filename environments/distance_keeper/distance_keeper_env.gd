extends Node3D
class_name DistanceKeeperEnv

@export var settings: DistanceKeeperEnvSettings
@export var agent: CharacterBody3D
@export var obstacle: CharacterBody3D


func reset_env():
	# reroll position for both objects
	var half_size = settings.env_size.x / 2
	agent.position = Vector3(randf_range(-half_size + 0.5, half_size - 2.0), 0.5, 0)
	obstacle.position = Vector3(randf_range(agent.position.x + 1.0, half_size - 0.5), 0.5, 0)