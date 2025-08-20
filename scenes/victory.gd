extends Node

func _ready() -> void:
	await get_tree().create_timer(1.5).timeout
	$AnimationPlayer.play("rave_bg")
	get_tree().quit()
