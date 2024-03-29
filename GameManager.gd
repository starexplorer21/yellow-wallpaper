extends Node2D

# make constants
var aggression = 1
var turn_count
var last_caught
var insanity
var took_door
var window_open
var energy
var door_timer
var aggression_timer

var being_caught
var not_playing = false
var whisper_timer = 0

var door_sound = load("res://assets/door.mp3")
var write_sound = load("res://assets/write.mp3")
var window_open_sound = load("res://assets/window_open.mp3")
var window_close_sound = load("res://assets/window_close.mp3")
var bed_sound = load("res://assets/bed.mp3")
var wake_sound = load("res://assets/wake.mp3")

# rng
var rng = RandomNumberGenerator.new()

# mark current interacting object

var curobj

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func init_game():
	$LoseScreen.visible = false
	$WinScreen.visible = false
	$Player.visible = true
	$Player.can_move = true
	$EnergyBar.visible = true
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
	#reset game
	curobj = "none"
	# set vignette
	$ColorRect.material.set_shader_parameter("inner_radius", 0.1)
	$ColorRect.material.set_shader_parameter("outer_radius", 1.4)
	$ColorRect.material.set_shader_parameter("alpha", 0.3)
	$EnergyBar.value = energy
	not_playing = true
	whisper_timer = 0
	being_caught = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	print(whisper_timer)
	if not_playing && whisper_timer > (10-aggression) * 100:
		var roll = rng.randf()
		if !being_caught and roll < aggression / 100.0:
			$WhisperPlayer.volume_db = -20 + aggression
			$WhisperPlayer.play()
			not_playing = false
			whisper_timer = 0
			print(whisper_timer)
			
		
	if Input.is_action_just_pressed("interact"):
		print("interacting")
		if curobj == "desk":
			await write()
		elif curobj == "window":
			await window()
		elif curobj == "door":
			await door()
		elif curobj == "bed":
			await bed()
	
	if not_playing:
		whisper_timer += 1
	
func write():
	var roll = rng.randi_range(0, 100)
	var threshold = 35 + (0.65 * aggression)
	energy -= 75
	$EnergyBar.value = energy
	if energy < 75:
		$Interact.visible = false
		curobj = "none"
	print(energy)
	# if you pass the roll, then get benefits
	if roll > threshold:
		insanity = max(0, insanity - 20)
		print(insanity)
		$EffectsPlayer.volume_db = 5
		$EffectsPlayer.stream = write_sound
		$EffectsPlayer.play(6)
	else:
		aggression += 2
		await discovered()
		await end_turn()
	
func door():
	var roll = rng.randi_range(0, 100)
	var threshold = 50
	energy -= 100
	if energy < 100:
		$Interact.visible = false
		curobj = "none"
	$EnergyBar.value = energy
	print(energy)
	
	if roll > threshold:
		insanity = 0
		print(insanity)
		$EffectsPlayer.volume_db = -15
		$EffectsPlayer.stream = door_sound
		$EffectsPlayer.play(2)
	else:
		aggression += 10
		await discovered()
		await end_turn()
		
func window():
	var roll = rng.randi_range(0, 100)
	var threshold = 20 + (8 * aggression)
	energy -= 25
	if energy < 25:
		$Interact.visible = false
		curobj = "none"
	$EnergyBar.value = energy
	print(energy)
	if roll > threshold:
		window_open = !window_open
		if window_open:
			$EffectsPlayer.volume_db = 5
			$EffectsPlayer.stream = window_open_sound
			$EffectsPlayer.play(3)
			$Interact/Label.text = "Close Window"
		else:
			$EffectsPlayer.volume_db = -5
			$EffectsPlayer.stream = window_close_sound
			$EffectsPlayer.play(1.2)
			$Interact/Label.text = "Open Window"
		print(insanity)
	else:
		aggression += 1
		await discovered()
		await end_turn()
		
func bed():
	# bed audio es muy malo
	#$EffectsPlayer.volume_db = 5
	#$EffectsPlayer.stream = bed_sound
	#$EffectsPlayer.play(4)
	end_turn()
	
func end_turn():
	print("end turn")
	# win and lose checking
	if turn_count >= 30:
		win()
		return
		
	# base insanity gain
	var insanity_gain = 5
	# open window bonus
	if window_open:
		insanity_gain = 3
		
	# turn baesd insanity gain
	
	insanity_gain += turn_count/7
	
	# insanity gain by aggression
	# base bonus
	# this is basically instant kill at 10
	# i think this introduces a strat where you 50/50 door 
	# turn 1
	insanity_gain += (insanity/10) * (0.35) * aggression
	# multiplier
	insanity_gain *= 1 + (aggression * 0.15)
	
	# door applies last
	if took_door:
		insanity_gain /= 2
	
	# gain insanity
	insanity += insanity_gain
	
	# reset energy
	energy = 105
	
	# turn based aggression reduction
	if last_caught >= 1:
		last_caught += 1
	if last_caught == 5:
		last_caught = 0
		if aggression > 1:
			aggression -= 1

	print(last_caught)
	print(aggression)
	
	# lower by aggression
	energy -= (aggression) * 5
	$EnergyBar.value = energy
		
	# door counters
	if took_door:
		door_timer += 1
	
	# turn off door blocker. 
	if door_timer == 5:
		took_door = false
	
	print(energy)
	print(insanity)
	
	if insanity >= 100:
		lose()
		return
	
	# show the end day thing
	$EffectsPlayer.stream = wake_sound
	$EffectsPlayer.volume_db = -20
	$EffectsPlayer.play()
	turn_count += 1
	$DayEnd.visible = true
	$Player.position = Vector2(0, 0)
	$Player.can_move = false
	await get_tree().create_timer(3.0).timeout
	$Player.can_move = true
	$DayEnd.visible = false
	print(turn_count)
	# change vignette:
	$ColorRect.material.set_shader_parameter("alpha", insanity/100)
	being_caught = false
	
func lose():
	$LoseScreen.visible = true
	$Player.position = Vector2(0, 0)
	$Player.can_move = false
	
func win():
	$WinScreen.visible = true
	$Player.position = Vector2(0, 0)
	$Player.can_move = false
	

func discovered():
	being_caught = true
	last_caught = 1
	$Discovered.visible = true
	$EnergyBar.visible = false
	window_open = false
	$Player.position = Vector2(0, 0)
	$Player.can_move = false
	$EffectsPlayer.stream = door_sound
	$EffectsPlayer.volume_db = -15
	$EffectsPlayer.play(2)
	$WhisperPlayer.stop()
	not_playing = true
	await get_tree().create_timer(2.0).timeout
	$Player.can_move = true
	$Discovered.visible = false
	$EnergyBar.visible = true

func _on_desk_interact_body_entered(body):
	if body.name == "Player":
		if energy >= 75:
			$Interact.visible = true
			$Interact/Label.text = "Write"
			curobj = "desk"


func _on_desk_interact_body_exited(body):
	if curobj == "desk":
		$Interact.visible = false
		curobj = "none"


func _on_bed_interact_body_entered(body):
	if body.name == "Player":
		$Interact.visible = true
		$Interact/Label.text = "Go To Sleep"
		curobj = "bed"


func _on_bed_interact_body_exited(body):
	if curobj == "bed":
		$Interact.visible = false
		curobj = "none"


func _on_door_interact_body_entered(body):
	if body.name == "Player":
		if energy >= 100:
			$Interact.visible = true
			$Interact/Label.text = "Go Outside"
			curobj = "door"


func _on_door_interact_body_exited(body):
	if curobj == "door":
		$Interact.visible = false
		curobj = "none"


func _on_window_interact_body_entered(body):
	if body.name == "Player":
		if energy >= 25:
			$Interact.visible = true
			if window_open:
				$Interact/Label.text = "Close Window"
			else:
				$Interact/Label.text = "Open Window"
			curobj = "window"


func _on_window_interact_body_exited(body):
	if curobj == "window":
		$Interact.visible = false
		curobj = "none"

# restart script
func _on_button_pressed():
	init_game()


func _on_background_finished():
	$Background.play(0.0)


func _on_whisper_player_finished():
	not_playing = true
