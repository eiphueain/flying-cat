extends Area2D
@onready var sfx_hit: AudioStreamPlayer = $sfx_hit
var hit_sound_played : bool = false

signal hit
signal scored

func _on_body_entered(body):
	hit.emit()
	if hit_sound_played == false:
		$sfx_hit.play()
		hit_sound_played = true

func _on_score_area_body_entered(body: Node2D) -> void:
	scored.emit()
