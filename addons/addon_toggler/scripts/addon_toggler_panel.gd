@tool
extends PanelContainer

signal setting_pressed
signal addon_shortcut_toggled(addon_name : String, is_active : bool)

var addon_monitor_toggler_scene = load("uid://ck4weuiwm62x8")
var addon_active_toggler_scene = load("uid://b80ux6ndiwd1a")

@onready var settings_popup: PopupPanel = $SettingsPopup
@onready var option_btn: Button = %OptionBtn
@onready var settings_vbox: VBoxContainer = %SettingsVbox
@onready var ui_hbox: HBoxContainer = $UIHbox

var addon_status_dict : Dictionary[String, bool]

func _ready() -> void:
	settings_popup.close_requested.connect(_on_settings_popup_close)
	$SettingsPopup.hide()

func set_title_font(font : Font):
	%AddonTitle.set("theme_override_fonts/font", font)

func set_panel_color(color : Color):
	var panel : StyleBoxFlat = self.get("theme_override_styles/panel")
	panel.bg_color = color

func set_panel_border_color(color : Color):
	var panel : StyleBoxFlat = self.get("theme_override_styles/panel")
	panel.border_color = color

func set_setting_btn_color(color : Color):
	var panel : StyleBoxFlat = %OptionBtn.get("theme_override_styles/normal")
	panel.bg_color = color

#func _on_option_btn_toggled(toggled_on: bool) -> void:
	#if toggled_on:
func _on_option_btn_pressed() -> void:
	setting_pressed.emit() # parse all addon names names

func open_setting_and_parse(_addon_status_dict : Dictionary[String, bool]):
	addon_status_dict = _addon_status_dict
	var addons_on_shortcut : Array = get_addons_on_shortcut_box()
	
	for addon_name in addon_status_dict.keys():
		var new_toggler : Container = addon_monitor_toggler_scene.instantiate()

		new_toggler.set_label_text(addon_name)
		new_toggler.name = addon_name
		new_toggler.set_checkbox_active(addon_name in addons_on_shortcut)
		new_toggler.individual_addon_toggled.connect(
			_on_addon_shortcut_toggled #func(): addon_shortcut_toggled.emit()
			)
			
		settings_vbox.add_child(new_toggler)
	
	settings_popup.position = Vector2i(option_btn.global_position + (option_btn.size / 2.0)) + Vector2i(0, option_btn.size.y)
	settings_popup.show()

func _on_settings_popup_close():
	for child in settings_vbox.get_children():
		if !child.is_in_group("dont_free"):
			child.queue_free()

func get_addons_on_shortcut_box() -> Array:
	var addons = Array()
	for node in ui_hbox.get_children():
		if !node.is_in_group("dont_free"):
			addons.append(node.name)
	return addons

func _on_addon_shortcut_toggled(addon_name : String, is_active : bool):
	if is_active:
		var new_active_toggler : Container = addon_active_toggler_scene.instantiate()
		var editor_base_color = self.get_theme_color("base_color", "Editor")
		
		new_active_toggler.set_panel_color(editor_base_color)
		#new_toggler.addon_active_toggled.connect(_on_addon_active_toggled)
		new_active_toggler.set_label_text(addon_name)
		#new_active_toggler.individual_addon_toggled.connect()
		new_active_toggler.set_checkbox_active(EditorInterface.is_plugin_enabled(addon_name))
		new_active_toggler.name = addon_name
		
		ui_hbox.add_child(new_active_toggler)
		
	else:
		if ui_hbox.has_node(addon_name):
			var active_toggler = ui_hbox.get_node(addon_name)
			active_toggler.queue_free()

#func _on_addon_active_toggled(addon_name: String, toggled_on : bool):
	#EditorInterface.set_plugin_enabled(addon_name, toggled_on)
