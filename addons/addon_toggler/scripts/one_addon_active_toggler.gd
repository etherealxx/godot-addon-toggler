@tool
extends HBoxContainer

var is_properly_set_up := false

#signal addon_active_toggled(addon_name: String, toggled_on : bool)

func set_label_text(_text : String):
	#$Label.text = _text
	$CheckBox.text = _text

func set_checkbox_active(pressed : bool):
	$CheckBox.button_pressed = pressed
	is_properly_set_up = true

func _on_check_box_toggled(toggled_on: bool) -> void:
	if is_properly_set_up:
		EditorInterface.set_plugin_enabled($CheckBox.text, toggled_on)
		#addon_active_toggled.emit($Label.text, toggled_on)

func set_panel_color(color : Color):
	var panel : StyleBoxFlat = $Panel.get("theme_override_styles/panel")
	panel.bg_color = color
