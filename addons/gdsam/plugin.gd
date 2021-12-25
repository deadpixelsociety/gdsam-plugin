tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("GDSAM", "Node", preload("gdsam.gd"), preload("editor_icon.png"))


func _exit_tree():
	remove_custom_type("GDSAM")
