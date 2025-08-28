extends Node

func _ready() -> void:
	$Sprite2D.hide()
	$Sprite2D2.hide()
	$Sprite2D3.hide()
	$Sprite2D4.hide()
	$Sprite2D5.hide()
	$Label.show()
	await get_tree().create_timer(3).timeout
	$Label.hide()
	await get_tree().create_timer(1).timeout
	$AnimationPlayer.play("rave_bg")
	await $AnimationPlayer.animation_finished
	get_tree().quit()
	
