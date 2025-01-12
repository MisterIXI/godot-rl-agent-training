extends EnvSettingsBase
class_name TurtlePusherEnvSettings

@export var spawn_margin: float = 0.1
@export_group("Reward Settings")
## The reward for success
@export var reward_success: float = 5.0
## The reward for failure
@export var reward_failure: float = -5.0
## The reward for pushing the ball
@export var reward_pushing: float = 0.1
## The reward for being close to the ball
@export var reward_close_to_ball: float = 0.3

