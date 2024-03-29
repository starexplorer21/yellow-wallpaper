extends Node2D

var timer = 0
var counter = 0
var background_open = false

# check to see if we've seen tutorial
var seen_tutorial

var rng = RandomNumberGenerator.new()
var flicker_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("../Player").visible = false
	get_node("../Player").can_move = false
	get_node("../EnergyBar").visible = false
	$Tutorial.visible = false
	load_game()
	$Title/background.visible = seen_tutorial
	$Title/tutorial.visible = seen_tutorial
	

func load_game():
	if not FileAccess.file_exists("./savegame.save"):
		return # Error! We don't have a save to load.
	
	var save_game = FileAccess.open("./savegame.save", FileAccess.READ)
	
	var json_string = save_game.get_line()

	# Creates the helper class to interact with JSON
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string, skip in case of failure
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return

	# Get the data from the JSON object
	var node_data = json.get_data()
	
	seen_tutorial = node_data["tutorial"]
	print(seen_tutorial)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if rng.randf() > 0.90 and !background_open and flicker_timer > 100:
		$Title/GlitchText.text = "BEST"
		$Title/GlitchText.modulate = Color(1,0,0,1)
		await get_tree().create_timer(0.125).timeout
		$Title/GlitchText.text = "Rest"
		$Title/GlitchText.modulate = Color(1,1,1,1)
		flicker_timer = 0

	if background_open:
		if Input.is_action_just_pressed("interact"):
			$Background.visible = false
			background_open = false
			if seen_tutorial:
				$Tutorial.start_tutorial()
		if timer == 60:
			timer = 0
			counter += 1
			$Background/RichTextLabel.scroll_to_line(counter)
		# I should write a stop, i'm also lazy. 
		timer+=1
	
	flicker_timer += 1


func _on_button_pressed():
	start_game()

func start_game():
	# hide title first: 
	$Title.visible = false
	# show background information
	# won't show again if already shown with tutorial
	if seen_tutorial:
		get_node("..").init_game()
	else:
		$Background.visible = true
		background_open = true
	
	


func _on_background_pressed():
	$Title.visible = false
	$Background.visible = true
	background_open = true

func _on_tutorial_pressed():
	$Title.visible = false
	$Tutorial.start_tutorial()
