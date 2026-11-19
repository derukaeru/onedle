extends Control

var valid_words: Dictionary = {}
var answers: Array[String] = []

@onready var letters: HBoxContainer = $container/letters
@onready var end_screen: Control = $container/end_screen
@onready var continue_button: Button = $container/continue
@onready var guesses_label: Label = $container/guesses
@onready var letters_animation: AnimationPlayer = $container/LettersAnimationPlayer
@onready var end_screen_animation: AnimationPlayer = $container/end_screen/AnimationPlayer
@onready var correct_answer: Label = $container/end_screen/WrongPanel/correct_answer
@onready var correct_panel: Panel = $container/end_screen/CorrectPanel
@onready var wrong_panel: Panel = $container/end_screen/WrongPanel
@onready var correct_particle: GPUParticles2D = $container/correct_particle

var letter_boxes: Array[Panel] = []

var word_length: int = 5
var can_type: bool = true
var can_continue: bool = false 
var was_correct: bool = false

var max_guesses: int = 6
var guesses: int = max_guesses

var current_guess: String = ""
var answer: String = ""

func _ready() -> void:
	load_word_list("res://words/valid.txt", valid_words)
	answers = load_word_list("res://words/answers.txt")
	
	EventManager.key_pressed.connect(set_letter)
	
	for box in letters.get_children():
		letter_boxes.append(box)
	
	new_word()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key: = OS.get_keycode_string(event.keycode).to_upper()
		
		if key.length() == 1 and key >= "A" and key <= "Z" and can_type:
			add_letter(key)
		elif event.keycode == KEY_BACKSPACE and can_type:
			remove_letter()
		elif event.keycode == KEY_ENTER:
			if can_type:
				submit_guess()
			else: 
				clear()

func set_letter(letter: String) -> void:
	add_letter(letter)

func add_letter(val: String) -> void:
	if current_guess.length() >= word_length: return
	current_guess += val
	
	update_letter()

func remove_letter() -> void:
	if current_guess.length() <= 0: return
	current_guess = current_guess.left(-1)
	
	update_letter()

func update_letter() -> void:
	for i in range(word_length):
		if i < current_guess.length():
			pass
			letter_boxes[i].set_letter(current_guess[i])
		else:
			pass
			letter_boxes[i].set_letter("")

func submit_guess() -> void:
	if current_guess.length() != word_length: return
	current_guess = current_guess.to_lower()
	
	if not valid_words.has(current_guess): 
		letters_animation.play("invalid")
		return
		
	guesses -= 1
	reveal_guess()
	
	can_type = false
	guesses_label.text = "Guesses: %d" % guesses

func reveal_guess() -> void:
	for i in range(word_length):
		await get_tree().create_timer(0.2).timeout
		letter_boxes[i].reveal_letter(i, answer)
	
	await get_tree().create_timer(0.2).timeout
	
	if current_guess == answer:
		await get_tree().create_timer(0.8).timeout
		
		end_screen.show()
		correct_panel.show()
		was_correct = true
		can_type = false
		
		end_screen_animation.play("open_correct")
		await end_screen_animation.animation_finished
		correct_particle.emitting = true
	elif guesses <= 0:
		await get_tree().create_timer(0.8).timeout
		end_screen.show()
		wrong_panel.show()
		end_screen_animation.play("open_wrong")
		correct_answer.text = "Answer: " + answer.to_upper()
		was_correct = false
		
		can_type = false
	else:
		can_continue = true
		continue_button.show()

func backspace(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo():
		remove_letter()

func enter(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo():
		if can_type:
			submit_guess()
		else:
			clear()

func load_word_list(dir: String, dictionary: Dictionary = {}) -> Array[String]:
	var words: Array[String] = []
	
	var file := FileAccess.open(dir, FileAccess.READ)
	if file == null:
		push_error("could not read file")
		return words
	
	while not file.eof_reached():
		var word := file.get_line().strip_edges().to_lower()
		
		if word.length() != word_length:
			continue
		
		words.append(word)
		dictionary[word] = true
	
	return words

func new_word() -> void:
	answer = answers.pick_random()
	can_type = true

func clear() -> void:
	if not can_continue: return
	
	for i in range(word_length):
		await get_tree().create_timer(0.1).timeout
		letter_boxes[i].reset()
	
	can_type = true
	can_continue = false
	current_guess = ""
	continue_button.hide()

func restart() -> void:
	for i in range(word_length):
		letter_boxes[i].reset()
	
	can_type = true
	can_continue = false
	continue_button.hide()
	
	if was_correct:
		end_screen_animation.play_backwards("open_correct")
	else:
		end_screen_animation.play_backwards("open_wrong")
	
	new_word()
	continue_button.hide()
	guesses = 6
	guesses_label.text = "Guesses: 6"
	current_guess = ""
	
	await end_screen_animation.animation_finished
	end_screen.hide()
	
	correct_panel.hide()
	wrong_panel.hide()
