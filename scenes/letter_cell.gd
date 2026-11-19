extends Panel

@onready var label: Label = $Label
@onready var animation: AnimationPlayer = $AnimationPlayer
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

func reveal_letter(index: int, answer: String) -> void:
	animation.play("hide")
	await animation.animation_finished
	
	if answer[index] == letter.to_lower():
		set_color(Color("68af4c"))
	elif answer.contains(letter.to_lower()):
		set_color(Color("#a89c48"))
	else:
		set_color(Color("#313131"))
	
	animation.play("reveal")

func reset() -> void:
	animation.play("clear")
	await animation.animation_finished
	
	set_color(Color("313131"))
	set_letter("")
	animation.play("RESET")
