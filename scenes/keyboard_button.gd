@tool
extends Panel

@onready var label: Label = $Label

@export var letter: String

func _ready() -> void:
	label.text = letter

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		EventManager.key_pressed.emit(letter)
