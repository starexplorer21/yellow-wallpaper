extends Control

var frame

# Called when the node enters the scene tree for the first time.
func _ready():
	start_tutorial()

func start_tutorial():
	visible = true
	$Right.disabled = false
	$Left.disabled = false
	frame = 1
	var path = "Frame"+str(frame)
	get_node(path).visible = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func mark_tutorial():
	var save_game = FileAccess.open("./savegame.save", FileAccess.WRITE)
	var save_dict = {"tutorial": true}
	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(save_dict)

	# Store the save dictionary as a new line in the save file.
	save_game.store_line(json_string)

func _on_right_pressed():
	if frame < 7:
		var path1 = "Frame"+str(frame)
		get_node(path1).visible = false
		frame += 1
		var path2 = "Frame"+str(frame)
		get_node(path2).visible = true
	else:
		mark_tutorial()
		get_node("../../").init_game()
		$Right.disabled = true
		$Left.disabled = true
		visible = false

func _on_left_pressed():
	if frame > 1:
		var path1 = "Frame"+str(frame)
		get_node(path1).visible = false
		frame -= 1
		var path2 = "Frame"+str(frame)
		get_node(path2).visible = true
