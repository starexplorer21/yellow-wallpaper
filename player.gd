extends CharacterBody2D


const SPEED = 1
var lastdir: Vector2 = Vector2.ZERO
var can_move = true

func _physics_process(delta):
	
	if can_move:
		var dir = Vector2.ZERO
			
		if Input.is_action_pressed("up"):
			dir.y = -1
		elif Input.is_action_pressed("down"):
			dir.y = 1	
		if Input.is_action_pressed("left"):
			dir.x = -1	
		elif Input.is_action_pressed("right"):
			dir.x = 1		

		move_and_collide(dir * SPEED)
		
		if dir.length() > 0:
			if dir.x > 0:
				$AnimatedSprite2D.play("walk_right")
			elif dir.x < 0:
				$AnimatedSprite2D.play("walk_left")
			elif dir.y > 0:
				$AnimatedSprite2D.play("walk_down")
			elif dir.y < 0:
				$AnimatedSprite2D.play("walk_up")
		else:
			if lastdir.x > 0:
				$AnimatedSprite2D.play("idle_right")
			elif lastdir.x < 0:
				$AnimatedSprite2D.play("idle_left")
			elif lastdir.y > 0:
				$AnimatedSprite2D.play("idle_down")
			elif lastdir.y < 0:
				$AnimatedSprite2D.play("idle_up")
		
		lastdir = dir

