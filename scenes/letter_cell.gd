extends Panel

@onready var label: Label = $Label
var letter: String = ""

func set_letter(value: String) -> void:
	label.text = value
	letter = value

func set_color(color: Color) -> void:
	var style := StyleBoxFlat.new()
	
	style.bg_color = color
	
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	
	add_theme_stylebox_override("panel", style)
