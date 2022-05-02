extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$TimeupWarnTimer.start()
	$TimeupTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PlayerPowerUp_body_entered(body):
	if "Mob" in body.get_name():
		$AudioStreamPlayer2D.play()
		body.hide()
		body.queue_free()
		#if $Timer.is_stopped():
			#$Timer.start()
			#$AnimationPlayer.play("Shock")


func _on_Timer_timeout():
	$AnimationPlayer.stop(true)
	pass


func _on_TimeupTimer_timeout():
	queue_free()


func _on_TimeupWarnTimer_timeout():
	$AnimationPlayer2.play("New Anim")
