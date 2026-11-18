@tool
extends Panel

@onready var label: Label = $Label

@export var letter: String:
	set(val):
		label.text = val
		letter = val

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		print('clicked')
