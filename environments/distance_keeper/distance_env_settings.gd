extends EnvSettingsBase
class_name DistanceKeeperEnvSettings

@export_group("Env Settings")
@export var obstacle_margin: float = 3

@export_group("Physic Settings")
@export var max_agent_speed: float = 15
@export var max_obstacle_speed: float = 10

@export_group("Reward Settings")
@export var target_dist: float = 5
@export var fixed_penalty: float = -3

