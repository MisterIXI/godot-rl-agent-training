extends Resource
class_name EnvSettingsBase

@export_group("General Settings")
## The size of the environment in x and y
@export var env_size : Vector2 = Vector2(0,0)
## The space in x and y should be added when spawned in batch environment
@export var env_margin: Vector2 = Vector2(3,3)
## The count of agents in the environment
@export var env_count: Vector2i = Vector2i(1,1)

@export_group("Sync Node Settings")
enum ControlModes { HUMAN, TRAINING, ONNX_INFERENCE }
@export var control_mode: ControlModes = ControlModes.TRAINING
@export var action_repeat: int = 8
@export var speed_up: float = 1.0
@export var onnx_model_path := ""

@export_group("Camera Settings")
@export var camera_pos: Vector3 = Vector3(0, 10, 0)
@export var camera_rot: Vector3 = Vector3(1.57, 0, 0)
func _to_string() -> String:
	return (
		"EnvSize: " + str(env_size) + "\n" +
		"EnvCount: " + str(env_count) + "\n" +
		"action_repeat: " + str(action_repeat) + "\n" +
		"SpeedUp: " + str(speed_up) + "\n"
	)