extends Node

@export var pipe_scene : PackedScene

@onready var sfx_swoosh: AudioStreamPlayer = $sfx_swoosh
@onready var sfx_score: AudioStreamPlayer = $sfx_score
@onready var sfx_fall: AudioStreamPlayer = $sfx_fall
@onready var scene_transition_animation= $SceneTransitionAnimation/AnimationPlayer

var game_running: bool = false
var game_over : bool = false
var score : int
var scroll 
const SCROLL_SPEED : int = 200
var game_over_position : float
var win_position : float
var win_condition_reached : bool = false
var screen_size : Vector2i
var pipes : Array
const PIPE_DELAY : int = 200
const PIPE_RANGE : int = 200
var fall_sound_played : bool

func _ready():
	screen_size = get_window().size
	new_game()
	
func new_game():
	score = 25
	$ScoreLabel.text = "Score: " + str(score)
	game_over= false
	game_running = false
	$Game_over.hide()
	$Portal.hide()
	get_tree().call_group("pipes", "queue_free")
	pipes.clear()
	generate_pipe()
	$Cat.reset()
	$Background.scroll_offset.x = 0
	fall_sound_played = false

func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
					$sfx_swoosh.play()
				else:
					if $Cat.flying:
						$Cat.jump()
						check_top()

func start_game():
	game_running = true
	$Cat.flying = true
	$Cat.jump()
	$PipeTimer.start()

func _process(delta):
	if game_running:
		$Background.scroll_offset.x -= SCROLL_SPEED * delta
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED * 4 * delta
	else:
		$Background.scroll_offset.x = 0
	if $Cat.falling == true:
		$Background.scroll_offset.x = game_over_position
	if win_condition_reached == true:
		$Background.scroll_offset.x = win_position
		$Portal.show()
		cat_move(delta)
	
func check_top():
	if $Cat.position.y < 0:
		$Cat.falling = true
		stop_game()

func stop_game():
	$Cat.flying = false
	$PipeTimer.stop()
	$Game_over.show()
	game_running = false
	game_over = true
	game_over_position = $Background.get_scroll_offset().x
	if fall_sound_played == false:
		$sfx_fall.play()
		fall_sound_played = true
	

func _on_pipe_timer_timeout() -> void:
	if score < 28:
		generate_pipe()
	elif score == 29:
		await get_tree().create_timer(1).timeout
		win_position = $Background.get_scroll_offset().x
		win_condition_reached = true

func generate_pipe():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = screen_size.y / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(cat_hit)
	pipe.scored.connect(scored)
	add_child(pipe)
	pipes.append(pipe) 

func cat_move(delta):
	$Cat.position.x += SCROLL_SPEED * 2 * delta
	
func scored():
	score += 1
	$ScoreLabel.text = "Score: " + str(score)
	$sfx_score.play()
	
func cat_hit():
	$Cat.falling = true
	stop_game()
	
func _on_game_over_restart():
	new_game()

func _on_ground_hit() -> void:
	$Cat.falling = true
	stop_game()

func _on_portal_body_entered(body: Node2D) -> void:
	scene_transition_animation.play("fade_in")
	await  get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/victory.tscn")
