@tool
extends EditorPlugin

var addon_toggler_scene = load("uid://ccvseql2gmp6k")

var addon_toggler_node : Control

func _enter_tree() -> void:
	addon_toggler_node = addon_toggler_scene.instantiate()

func _ready() -> void:
	#print("addon activated")
	if Engine.is_editor_hint():
		
		addon_toggler_node.setting_pressed.connect(_on_setting_button_pressed)
		#addon_toggler_node.addon_shortcut_toggled.connect(_on_addon_shortcut_toggled)
		
		# setup theme to match editor theme
		addon_toggler_node.set_theme( EditorInterface.get_editor_theme() )
		var title_font = addon_toggler_node.get_theme_font("title", "EditorFonts")
		addon_toggler_node.set_title_font(title_font)
		var disabled_panel_color = addon_toggler_node.get_theme_color("disabled_border_color", "Editor")
		addon_toggler_node.set_panel_color(disabled_panel_color)
		var editor_base_color = addon_toggler_node.get_theme_color("base_color", "Editor")
		addon_toggler_node.set_panel_border_color(editor_base_color)
		var editor_dark_color_2 = addon_toggler_node.get_theme_color("dark_color_2", "Editor")
		addon_toggler_node.set_setting_btn_color(editor_dark_color_2)
		
		add_control_to_container(CONTAINER_TOOLBAR, addon_toggler_node)
		var editor_title_bar = addon_toggler_node.get_parent()

		#editor_run_bar.add_sibling(addon_toggler_node)

		# move addon position to the left of play button
		var editor_run_bar : Node
		for child in editor_title_bar.get_children():
			if "EditorRunBar" in child.name:
				editor_run_bar = child
				break
		
		var run_bar_index = editor_run_bar.get_index()
		editor_title_bar.move_child(addon_toggler_node, run_bar_index)
		
		#print("---")
		#for child in editor_title_bar.get_children():
			#print(child.name)

func _on_setting_button_pressed():
	var dir = DirAccess.open("res://addons")
	#var addons_on_shortcut : Array = addon_toggler_node.get_addons_on_shortcut_box()
	var addon_name_list_temp = dir.get_directories()
	var addon_name_status_dict : Dictionary[String, bool]
	for addon_dir_name : String in addon_name_list_temp:
		# fix this later to not rely on text string
		if (addon_dir_name != "addon_toggler"): # and (addon_dir_name not in addons_on_shortcut):
			addon_name_status_dict[addon_dir_name] = EditorInterface.is_plugin_enabled(addon_dir_name)
	addon_toggler_node.open_setting_and_parse(addon_name_status_dict)
	
#func _on_addon_shortcut_toggled(addon_name : String, is_active : bool):
	#pass

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		remove_control_from_container(CONTAINER_TOOLBAR, addon_toggler_node)
		if addon_toggler_node:
			addon_toggler_node.queue_free()
