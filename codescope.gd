@tool
extends EditorPlugin

# Constants
const DOCK_PATH = "res://addons/codescope/CodeScope.tscn"
const GLOBAL_SCRIPT_PATH = "res://addons/codescope/globals.gd"
const AUTOLOAD_NAME = "Codals"  # Use PascalCase for autoload names as per the GDScript style guide.

# Member variable for the dock instance.
var dock: Control

func _enter_tree() -> void:
	# Instantiate and add the dock to the editor UI.
	dock = preload(DOCK_PATH).instantiate() as Control
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)

	# Add the autoload singleton (uncomment this if needed).
	if not Engine.has_singleton(AUTOLOAD_NAME):
		add_autoload_singleton(AUTOLOAD_NAME, GLOBAL_SCRIPT_PATH)

func _exit_tree() -> void:
	# Safely remove dock and singleton when the plugin is unloaded.
	if dock:
		remove_control_from_docks(dock)
		dock.queue_free()

	if Engine.has_singleton(AUTOLOAD_NAME):
		remove_autoload_singleton(AUTOLOAD_NAME)
