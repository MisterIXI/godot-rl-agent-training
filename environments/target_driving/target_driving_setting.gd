extends EnvSettingsBase
class_name TargetDrivingEnvSetting

@export var spawn_margin: float = 0.1
@export_group("Reward Settings")
## The reward for success
@export var reward_success: float = 5.0
## The reward for failure
@export var reward_failure: float = -5.0