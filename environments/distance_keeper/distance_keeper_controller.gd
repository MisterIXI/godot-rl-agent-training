extends Node3D
class_name DistanceAIController
# TODO: refactor needed with current knowledge

enum ControlModes { INHERIT_FROM_SYNC, HUMAN, TRAINING, ONNX_INFERENCE, RECORD_EXPERT_DEMOS }
@export var control_mode: ControlModes = ControlModes.INHERIT_FROM_SYNC
@export var onnx_model_path := ""
@export var reset_after := 20

@export_group("Record expert demos mode options")
## Path where the demos will be saved. The file can later be used for imitation learning.
@export var expert_demo_save_path: String
## The action that erases the last recorded episode from the currently recorded data.
@export var remove_last_episode_key: InputEvent
## Action will be repeated for n frames. Will introduce control lag if larger than 1.
## Can be used to ensure that action_repeat on inference and training matches
## the recorded demonstrations.
@export var action_repeat: int = 1

@export_group("Multi-policy mode options")
## Allows you to set certain agents to use different policies.
## Changing has no effect with default SB3 training. Works with Rllib example.
## Tutorial: https://github.com/edbeeching/godot_rl_agents/blob/main/docs/TRAINING_MULTIPLE_POLICIES.md
@export var policy_name: String = "shared_policy"

var onnx_model: ONNXModel

var heuristic := "human"
var done := false
var reward := 0.0
var n_steps := 0
var needs_reset := false

var _player: DistanceKeeperAgent
var _env: DistanceKeeperEnv
var move := Vector2.ZERO

func _ready():
	add_to_group("AGENT")


func init(player: Node3D, env: DistanceKeeperEnv):
	_player = player
	_env = env


#-- Methods that need implementing using the "extend script" option in Godot --#
func get_obs() -> Dictionary:
	return {"obs":[
		_player.sensor_output,
	]}

func get_reward() -> float:	
	return _player.calc_reward() + reward
	
func get_action_space() -> Dictionary:
	return {
		"move" : {
			"size": 1,
			"action_type": "continuous"
		},
		}
	
func set_action(action) -> void:	
	move.x = action["move"][0]
	_player.move_input = move.x


#-----------------------------------------------------------------------------#


#-- Methods that sometimes need implementing using the "extend script" option in Godot --#
# Only needed if you are recording expert demos with this AIController
func get_action() -> Array:
	assert(false, "the get_action method is not implemented in extended AIController but demo_recorder is used")
	return []

# -----------------------------------------------------------------------------#


func _physics_process(_delta):
	n_steps += 1
	if n_steps > reset_after:
		needs_reset = true
	if needs_reset:
		reset()
	reset_if_done()


func get_obs_space():
	# may need overriding if the obs space is complex
	var obs = get_obs()
	return {
		"obs": {"size": [len(obs["obs"])], "space": "box"},
	}


func reset():
	n_steps = 0
	_env.reset_env()
	needs_reset = false


func reset_if_done():
	if done:
		reset()


func set_heuristic(h):
	# sets the heuristic from "human" or "model" nothing to change here
	heuristic = h


func get_done():
	return done


func set_done_false():
	done = false


func zero_reward():
	reward = 0.0

func get_info():
	return {}