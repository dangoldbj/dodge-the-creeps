extends Area2D
signal hit
signal coin_captured
signal power_up

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var speed = 400 # how fast the player will move (pixels/sec).
var screen_size # size of the game window

var _PowerUpScene = preload("res://scenes/PlayerPowerUp.tscn")
var powerup_instance = null

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	if velocity.x != 0:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0

func _input(event):
	$AnimatedSprite.stop()
	var deg = 130
	if event is InputEventScreenDrag:
		var pos = event.position
		var rel = event.relative
		var spx = event.speed.x / (max(pos.x - rel.x, 1) * deg)
		var spy = event.speed.y / (max(pos.y - rel.y, 1) * deg)
		
		position.x += ((pos.x + rel.x) * spx)
		position.y += ((pos.y + rel.y) * spy)
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.play()

func _on_Player_body_entered(body):
	if "Mob" in body.get_name():
		hide()
		emit_signal("hit")
		$CollisionShape2D.set_deferred("disabled", true)
	
	if "Coin" in body.get_name():
		emit_signal("coin_captured")
	
	if "Power" in body.get_name():
		if not is_instance_valid(powerup_instance):
			powerup_instance = _PowerUpScene.instance()
			add_child(powerup_instance)
			emit_signal("power_up")
			print_debug("POWER UP!!")

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func _on_TouchScreenButton_pressed():
	pass # Replace with function body.
