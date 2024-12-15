extends Resource
class_name EnvSettingsBase

@export_group("General Settings")
## The size of the environment in x and y
@export var env_size : Vector2 = Vector2(0,0)
## The space in x and y should be added when spawned in batch environment
@export var env_margin: Vector2 = Vector2(3,3)
## The count of agents in the environment
@export var agent_count: Vector2i = Vector2i(1,1)

@export_group("Sync Node Settings")
enum ControlModes { HUMAN, TRAINING, ONNX_INFERENCE }
@export var control_mode: ControlModes = ControlModes.TRAINING
@export var action_repeat: int = 8
@export var speed_up: float = 1.0
@export var onnx_model_path := ""