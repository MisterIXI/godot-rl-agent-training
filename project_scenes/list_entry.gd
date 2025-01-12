extends MarginContainer
class_name ListEntry

@export var image: TextureRect
@export var title_label: Label
@export var desc_label: Label
@export var settings_label: Label
var env_desc: EnvDescription
var env_loader: ProjectLoader

func _on_gui_input(event:InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			env_loader.load_env(env_desc)
