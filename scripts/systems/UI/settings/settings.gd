## options menu
extends Control


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
	SceneTransition.change_scene("res://scenes/UI/main_menu.tscn", "Blue1" )
	AudioManager.button_click_sound()
