extends CharacterBody2D
@onready var sfx_jump: AudioStreamPlayer = $sfx_jump

const GRAVITY : int = 1500
const MAX_VEL : int = 600
const JUMP_SPEED : int = -500 # how many pixels the cat jumps
var flying : bool = false
var falling : bool = false
const START_POS = Vector2(200,250)

#called when node is ready
func _ready():
	reset()

func reset():
	falling = false
	flying = false
	position = START_POS
	set_rotation(0)

func _physics_process(delta):
	if falling or flying:
		velocity.y += GRAVITY * delta
		#terminal velocity
		if velocity.y > MAX_VEL:
			velocity.y = MAX_VEL
		if flying:
			set_rotation(deg_to_rad(velocity.y * 0.01))
			$AnimatedSprite2D.play()
		elif falling:
			set_rotation(PI/2)
			$AnimatedSprite2D.stop()
		move_and_collide(velocity * delta)
	else:
		$AnimatedSprite2D.stop()
		
func jump():
	velocity.y = JUMP_SPEED
	$sfx_jump.play()
