extends TabBar
const input_button_scene = preload("res://scenes/UI/action_set_button.tscn")
@onready var action_list: VBoxContainer = $PanelContainer/ControlsMarginContainer/ControlsOptions/ScrollContainer/ActionList

var is_remapping = false
var action_to_remap = null
var remapping_button = null

var input_actions = {
	"move_left" : "Move left",
	"move_right" : "Move right",
	"switch" : "switch gravity",
	"Jump" : "Jump",
	"slide" : "Slide",
	"dash" : "Dash",
	"reset" : "Reset"
	
	
	
	
}



func _ready() -> void:
	_create_action_list()


func _create_action_list():
	InputMap.load_from_project_settings()
	for item in action_list.get_children():
		item.queue_free()
	
	for action in input_actions:
		var button : Button = input_button_scene.instantiate()
		var action_label : Label = button.find_child("LabelAction")
		var input_label : Label = button.find_child("LabelInput")
		
		action_label.text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
			
		else:
			input_label.text = ""
			
		
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))


func _on_input_button_pressed(button : Button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "press key to bind..."

func _input(event: InputEvent) -> void:
	if is_remapping:
		if (event is InputEventKey || (event is InputEventMouseButton && event.is_pressed())):
			
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
			
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			_update_action_list(remapping_button, event)
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			accept_event()


func _update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")
