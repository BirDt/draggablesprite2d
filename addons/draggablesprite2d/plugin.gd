@tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here.
	add_custom_type("DraggableSprite2D", "Area2D", preload("src/draggablesprite2d.gd"), preload("src/icon.png"))


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("DraggableSprite2D")
