extends Node2D

# make constants
var aggression
var turn_count
var last_caught
var insanity
var took_door
var window_open
var energy
var door_timer
var aggression_timer

# rng
var rng = RandomNumberGenerator.new()

# mark current interacting object

var curobj

# Called when the node enters the scene tree for the first time.
func _ready():
	aggression = 1
	turn_count = 0
	last_caught = 0
	insanity = 30
	took_door = false
	window_open = false
	energy = 100
	door_timer = 0
	aggression_timer = 0
	$Interact.visible = false
	curobj = "none"
	$ColorRect.material.set_shader_parameter("inner_radius", 0.6)
	$ColorRect.material.set_shader_parameter("outer_radius", 1.4)
	$ColorRect.material.set_shader_parameter("alpha", insanity/100)
	$EnergyBar.value = energy


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		print("interacting")
		if curobj == "desk":
			await write()
		elif curobj == "window":
			await window()
		elif curobj == "door":
			await door()
		elif curobj == "bed":
			await end_turn()
	
func write():
	var roll = rng.randi_range(0, 100)
	var threshold = 35 + (0.65 * aggression)
	print(roll)
	print(threshold)
	energy -= 75
	$EnergyBar.value = energy
	# if you pass the roll, then get benefits
	if roll > threshold:
		insanity = max(0, insanity - 5)
	else:
		aggression += 2
		await discovered()
		await end_turn()
	
func door():
	var roll = rng.randi_range(0, 100)
	var threshold = 50
	energy -= 100
	$EnergyBar.value = energy
	if roll > threshold:
		insanity = 0
	else:
		aggression += 10
		await discovered()
		await end_turn()
		
func window():
	var roll = rng.randi_range(0, 100)
	var threshold = 20 + (8 * aggression)
	energy -= 25
	$EnergyBar.value = energy
	if roll > threshold:
		window_open = true
	else:
		aggression += 1
		await discovered()
		await end_turn()
	
func end_turn():
	# base insanity gain
	var insanity_gain = 5
	# open window bonus
	if window_open:
		insanity_gain = 3
	
	# insanity gain by aggression
	# base bonus
	# this is basically instant kill at 10
	# i think this introduces a strat where you 50/50 door 
	# turn 1
	insanity_gain += insanity * (0.14) * aggression
	# multiplier
	insanity_gain *= 1 + (aggression * 1.3)
	
	# door applies last
	if took_door:
		insanity_gain /= 2
	
	# gain insanity
	insanity += insanity_gain
	
	# reset energy
	energy = 110
	print(insanity)
	
	# lower by aggression
	energy -= aggression * 10
	$EnergyBar.value = energy
	
	# turn based aggression reduction
	if turn_count == 4:
		turn_count = 0
		aggression = max(0, aggression - 1)
		
	# door counters
	if took_door:
		door_timer += 1
	
	# turn off door blocker. 
	if door_timer == 5:
		took_door = false
	
	# change vignette:
	$ColorRect.material.set_shader_parameter("alpha", insanity/100)
	# show the end day thing
	turn_count += 1
	$DayEnd.visible = true
	$Player.position = Vector2(0, 0)
	$Player.can_move = false
	await get_tree().create_timer(1.0).timeout
	$Player.can_move = true
	$DayEnd.visible = false
	

func discovered():
	$Discovered.visible = true
	$Player.position = Vector2(0, 0)
	$Player.can_move = false
	await get_tree().create_timer(2.0).timeout
	$Player.can_move = true
	$Discovered.visible = false

func _on_desk_interact_body_entered(body):
	if body.name == "Player":
		if energy >= 75:
			$Interact.visible = true
			$Interact/Label.text = "Write"
			curobj = "desk"


func _on_desk_interact_body_exited(body):
	print("bye")
	$Interact.visible = false
	curobj = "none"


func _on_bed_interact_body_entered(body):
	if body.name == "Player":
		$Interact.visible = true
		$Interact/Label.text = "Go To Sleep"
		curobj = "bed"


func _on_bed_interact_body_exited(body):
	print("bye")
	$Interact.visible = false
	curobj = "none"


func _on_door_interact_body_entered(body):
	if body.name == "Player":
		if energy >= 100:
			$Interact.visible = true
			$Interact/Label.text = "Go Outside"
			curobj = "door"


func _on_door_interact_body_exited(body):
	print("bye")
	$Interact.visible = false
	curobj = "none"


func _on_window_interact_body_entered(body):
	if body.name == "Player":
		if energy >= 25:
			$Interact.visible = true
			$Interact/Label.text = "Open Window"
			curobj = "window"


func _on_window_interact_body_exited(body):
	print("bye")
	$Interact.visible = false
	curobj = "none"
