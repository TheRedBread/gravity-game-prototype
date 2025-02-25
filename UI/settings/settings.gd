## options menu
extends Control

@onready var scroll_container: ScrollContainer = $MarginContainer/VBoxContainer/PanelContainer/MarginContainer/ScrollContainer
const SLIDER_CLICK = preload("res://UI/settings/slider_click.mp3")


func _ready() -> void:
	scroll_container.get_v_scroll_bar().scrolling.connect(_on_settings_scrolling)



## Finds option's index by its name
func get_option_by_string(item_to_select : String, oButton : OptionButton):
	if item_to_select == "0":
		return 5
	for i in oButton.get_item_count():
		var cur_text = oButton.get_item_text(i)
		if cur_text == item_to_select:
			return i
	
	return -1


### Quit to menu
func _on_button_pressed() -> void:
	SceneTransition.change_scene("res://UI/main menu/main_menu.tscn", "Blue1" )
	AudioManager.button_click_sound()

func _on_settings_scrolling():
	AudioManager.play_sound(SLIDER_CLICK, 0, 0.02, 2.5, 0.01, "Sound effects")
