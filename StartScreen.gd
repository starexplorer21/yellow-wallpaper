extends Node2D

var timer = 0
var counter = 0
var background_open = false


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("../Player").visible = false
	get_node("../Player").can_move = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if background_open:
		if timer == 75:
			timer = 0
			counter += 1
			$Background/RichTextLabel.scroll_to_line(counter)
		timer+=1
		


func _on_button_pressed():
	start_game()

func start_game():
	# hide title first: 
	$Title.visible = false
	# turn off button
	$Background.visible = true
	background_open = true
	
	
