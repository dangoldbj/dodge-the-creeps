extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (PackedScene) var Mob
export (PackedScene) var Coin
export (PackedScene) var PowerUp

var score
var mobs = []
var coin = null
var powerup = null
var screen_size

var max_villan = 9
var min_villan = 3
var villan_time_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().size
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var pnumber = 0

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	get_tree().call_group("mobs", "queue_free")
	free_coin()
	villan_time_count = 0
	$Music.stop()
	$DeathSound.play()

func new_game():
	score = 0
	mobs = []
	free_coin()
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()

func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_ScoreTimer_timeout():
	#score += 1
	#$HUD.update_score(score)
	if not is_instance_valid(coin):
		coin = Coin.instance()
		coin.position.x = randi() % int(screen_size.x - 100)
		coin.position.y = randi() % int(screen_size.y - 100)
		add_child(coin)
	
	var r = randi() % 82
	if not is_instance_valid(powerup) and (pnumber > r - 10 and pnumber < r + 10):
		powerup = PowerUp.instance()
		powerup.position.x = randi() % int(screen_size.x - 100)
		powerup.position.y = randi() % int(screen_size.y - 100)
		add_child(powerup)


func _on_MobTimer_timeout():
	$MobPath/MobSpawnLocation.offset = randi()
	villan_time_count += 1
	var new_mobs = []
	for mob in mobs:
		if is_instance_valid(mob) and not mob.is_queued_for_deletion():
			new_mobs.append(mob)
	
	mobs = new_mobs
	
	if len(mobs) < get_max_villan(score):
		var mob = Mob.instance()
		add_child(mob)
		mobs.append(mob)
		var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
		
		mob.position = $MobPath/MobSpawnLocation.position
		direction += rand_range(-PI / 4, PI / 4)
		mob.rotation = direction
		
		mob.linear_velocity = Vector2(rand_range(mob.min_speed, mob.max_speed), 0)
		mob.linear_velocity = mob.linear_velocity.rotated(direction)	
	if pnumber > 0 or len(mobs) > 5:
		pnumber = (score % len(mobs))  * len(mobs)
	else:
		pnumber = 0 if randi() % 21 > 17 else pnumber

func _on_coin_capture():
	score += 1
	$CoinSound.play()
	$HUD.update_score(score)
	free_coin()

func free_coin():
	if is_instance_valid(coin):
		coin.hide()
		coin.queue_free()

func free_powerup():
	if is_instance_valid(powerup):
		powerup.hide()
		powerup.queue_free()
				
func get_max_villan(c):
	if c <= 10:
		return 3
	elif c > 10 or c <= 30:
		return 6
	else:
		return 9
	
	return 9

func _on_Player_power_up():
	$PowerUpSound.play()
	pnumber = -20
	free_powerup()
