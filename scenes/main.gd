extends Node

@export var pipe_scene : PackedScene

var game_running: bool = false
var game_over : bool = false
var score : int
var scroll 
const SCROLL_SPEED : int = 200
var screen_size : Vector2i
var pipes : Array
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200

func _ready():
	screen_size = get_window().size
	new_game()
	
func new_game():
	score = 0
	$ScoreLabel.text = "Score: " + str(score)
	game_over= false
	game_running = false
	$Game_over.hide()
	get_tree().call_group("pipes", "queue_free")
	pipes.clear()
	generate_pipe()
	$Cat.reset()

func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Cat.flying:
						$Cat.jump()
						check_top_bottom()

func start_game():
	game_running = true
	$Cat.flying = true
	$Cat.jump()
	$PipeTimer.start()

func _process(delta):
	if game_running:
		$Background.scroll_offset.x -= SCROLL_SPEED * delta
		for pipe in pipes:
			pipe.position.x -= 3
	else:
		$Background.scroll_offset.x = 0
		
	
func check_top_bottom():
	if $Cat.position.y < 0 or $Cat.position.y > 648:
		$Cat.falling = true
		stop_game()

func stop_game():
	$Cat.flying = false
	$PipeTimer.stop()
	$Game_over.show()
	game_running = false
	game_over = true

func _on_pipe_timer_timeout() -> void:
	generate_pipe()

func generate_pipe():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = screen_size.y / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	add_child(pipe)
	pipes.append(pipe) 

func scored():
	score += 1
	$ScoreLabel.text = "Score: " + str(score)
	
func bird_hit():
	$Cat.falling = true
	stop_game()
	
func _on_game_over_restart():
	new_game()
