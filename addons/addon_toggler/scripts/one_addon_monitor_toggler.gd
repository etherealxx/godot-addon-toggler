@tool
extends HBoxContainer

signal individual_addon_toggled(addon_name: String, toggled_on : bool)

func set_label_text(_text : String):
	#$Label.text = _text
	$CheckBox.text = _text

func set_checkbox_active(pressed : bool):
	$CheckBox.button_pressed = pressed

func _on_check_box_toggled(toggled_on: bool) -> void:
	individual_addon_toggled.emit($CheckBox.text, toggled_on)

#func get_checkbox() -> CheckBox:
	#return $CheckBox
