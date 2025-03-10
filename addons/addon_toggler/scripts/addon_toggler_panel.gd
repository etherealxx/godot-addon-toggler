@tool
extends PanelContainer

const THIS_ADDON_FOLDER_NAME := "addon_toggler"

signal addon_shortcut_toggled(addon_name : String, is_active : bool)

var addon_monitor_toggler_scene = load("uid://ck4weuiwm62x8")
var addon_active_toggler_scene = load("uid://b80ux6ndiwd1a")

@onready var settings_popup: PopupPanel = $SettingsPopup
@onready var option_btn: Button = %OptionBtn
@onready var settings_vbox: VBoxContainer = %SettingsVbox
@onready var ui_hbox: HBoxContainer = $UIHbox

var addon_name_status_dict : Dictionary[String, bool]

func _ready() -> void:
	settings_popup.close_requested.connect(_on_settings_popup_close)
	ProjectSettings.settings_changed.connect(_on_project_settings_changed)
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

func iterate_dir_find_addon(current_dir: String, dir_name_list : PackedStringArray):
	for addon_dir_name : String in dir_name_list:
		var dir = DirAccess.open(current_dir.path_join(addon_dir_name))
		if addon_dir_name != THIS_ADDON_FOLDER_NAME and dir != null:
			if dir.file_exists("plugin.cfg"):
				addon_name_status_dict[addon_dir_name] = EditorInterface.is_plugin_enabled(addon_dir_name)
			else:
				# recursively find addon on folder that isn't an addon
				var subdir_name_list_temp = dir.get_directories()
				if subdir_name_list_temp.size() > 0:
					iterate_dir_find_addon(dir.get_current_dir(), subdir_name_list_temp)

func get_addons_on_shortcut_box() -> Array:
	var addons = Array()
	for node in ui_hbox.get_children():
		if !node.is_in_group("dont_free"):
			addons.append(node.name)
	return addons

func _on_option_btn_pressed() -> void:
	addon_name_status_dict.clear()
	var dir = DirAccess.open("res://addons")
	var addon_name_list_temp = dir.get_directories()
	iterate_dir_find_addon("res://addons", addon_name_list_temp)

	var addons_on_shortcut : Array = get_addons_on_shortcut_box()
	
	# make checkbox for every addon
	for addon_name in addon_name_status_dict.keys():
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

func _on_addon_shortcut_toggled(addon_name : String, is_active : bool):
	var addon_node_name = addon_name.validate_node_name()
	if is_active:
		var new_active_toggler : Container = addon_active_toggler_scene.instantiate()
		var editor_base_color = self.get_theme_color("base_color", "Editor")
		
		new_active_toggler.set_panel_color(editor_base_color)
		new_active_toggler.set_checkbox_active(EditorInterface.is_plugin_enabled(addon_name))
		new_active_toggler.set_addon_name(addon_name)
		new_active_toggler.name = addon_node_name
		
		ui_hbox.add_child(new_active_toggler)
		
	else:
		if ui_hbox.has_node(addon_node_name):
			var active_toggler = ui_hbox.get_node(addon_node_name)
			active_toggler.queue_free()

func _on_project_settings_changed():
	for addon_active_toggler in ui_hbox.get_children():
		if !addon_active_toggler.is_in_group("dont_free"):
			addon_active_toggler.recheck_active_status()
