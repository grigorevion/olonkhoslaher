extends CharacterBody2D

const SPEED = 600.0
const JUMP_VELOCITY = -1500.0
var gravity = 4000.0
var fall_multiplier = 1.5

var coyote_timer = 0.0
var jump_buffer_timer = 0.0

func _ready():
	print("СКРИПТ ЗАГРУЖЕН! ФИЗИКА ОБНОВЛЕНА!")

func _physics_process(delta: float) -> void:
	if is_on_floor():
		coyote_timer = 0.1
	else:
		coyote_timer -= delta
		
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = 0.1
	else:
		jump_buffer_timer -= delta

	if not is_on_floor():
		var current_gravity = gravity
		if velocity.y > 0:
			current_gravity *= fall_multiplier
		velocity.y += current_gravity * delta

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 4 * delta)

	move_and_slide()
