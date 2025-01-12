extends Node3D
class_name ProjectLoader
# @export_group("Sync_Settings")
## List of environments to load
@export var environments: Array[EnvDescription] = []
## When set, this environment will be loaded instantly instead of presenting the selection
@export var selection_override: EnvDescription = null
## The root node for the spawned environments
@export var env_root: Node3D
@export var list_entry_scene: PackedScene
@export var env_container: VBoxContainer
@export var selection_menu_node: Control
@export var connection_text: Panel
@export var camera: Camera3D
## The spawned sync node
var sync_node: Sync

func _ready():
	if selection_override:
		load_env(selection_override)
	else:
		# Show the selection screen
		for env in environments:
			var list_entry = list_entry_scene.instantiate() as ListEntry
			list_entry.image.texture = env.preview_image
			list_entry.title_label.text = env.name
			list_entry.desc_label.text = env.description
			list_entry.settings_label.text = env.settings._to_string()
			list_entry.env_desc = env
			list_entry.env_loader = self
			env_container.add_child(list_entry)
		pass

func load_env(env: EnvDescription):
	connection_text.show()
	selection_menu_node.hide()
	await get_tree().process_frame
	await get_tree().process_frame
	connection_text.hide()
	# move camera
	camera.position = env.settings.camera_pos
	camera.rotation_degrees = env.settings.camera_rot
	print("Loading environment: ", env.name)
	var settings = env.settings
	# Spawn the environments
	var x_offset = -(settings.env_count.x - 1) * (settings.env_size.x + settings.env_margin.x) / 2
	var y_offset = -(settings.env_count.y - 1) * (settings.env_size.y + settings.env_margin.y) / 2
	for x in range(settings.env_count.x):
		for y in range(settings.env_count.y):
			var env_instance = env.scene.instantiate()
			env_instance.name = env.name + "_env_" + str(x) + "_" + str(y)
			env_instance.position = Vector3(
				x * (settings.env_size.x + settings.env_margin.x) + x_offset,
				0,
				y * (settings.env_size.y + settings.env_margin.y) + y_offset
			)
			env_instance.settings = settings
			env_root.add_child(env_instance)
	# Spawn the sync node
	sync_node = Sync.new()
	sync_node.control_mode = settings.control_mode
	sync_node.action_repeat = settings.action_repeat
	sync_node.speed_up = settings.speed_up
	sync_node.onnx_model_path = settings.onnx_model_path
	add_child(sync_node)
