extends Control

var valid_words: Dictionary = {}
var answers: Array[String] = []

@onready var letters: HBoxContainer = $container/letters
@onready var end_screen: Control = $container/end_screen
@onready var continue_button: Button = $container/continue

@onready var letters_animation: AnimationPlayer = $container/LettersAnimationPlayer

var letter_boxes: Array[Panel] = []

var word_length: int = 5
var can_type: bool = true

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
	can_type = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key: = OS.get_keycode_string(event.keycode).to_upper()
		
		if key.length() == 1 and key >= "A" and key <= "Z" and can_type:
			add_letter(key)
		elif event.keycode == KEY_BACKSPACE and can_type:
			remove_letter()
		elif event.keycode == KEY_ENTER:
			submit_guess()

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
	
	if not valid_words.has(current_guess.to_lower()): 
		letters_animation.play("invalid")
		return
		
	guesses -= 1
	reveal_guess()
	can_type = false
	
	# if not guessed correct and no guesses left
	if guesses <= 0:
		# lose
		pass

func reveal_guess() -> void:
	for i in range(word_length):
		await get_tree().create_timer(0.2).timeout
		letter_boxes[i].reveal_letter(i, answer)

func reveal_answer() -> void:
	pass

func backspace(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo():
		remove_letter()

func enter(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo():
		submit_guess()

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

func clear() -> void:
	for i in range(word_length):
		pass
