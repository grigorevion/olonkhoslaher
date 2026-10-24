extends CharacterBody2D

const SPEED = 100.0
var gravity = 4000.0
var direction = 1
var hp = 3
var knockback_timer = 0.0

var wait_time = 1.0
var wait_timer = 0.0

var patrol_distance = 200.0
var start_position = Vector2.ZERO

func _ready():
	start_position = global_position
	patrol_distance = randf_range(100.0, 300.0)
	wait_time = randf_range(0.5, 2.0)
	direction = [-1, 1].pick_random()
	$Sprite2D.flip_h = direction < 0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	# Если враг получил удар (в стане)
	if knockback_timer > 0.0:
		knockback_timer -= delta
		velocity.x = move_toward(velocity.x, 0, 1500 * delta)
	else:
		# Если таймер ожидания активен — стоим на месте
		if wait_timer > 0.0:
			wait_timer -= delta
			velocity.x = 0
		else:
			velocity.x = direction * SPEED
			
			# Проверяем края
			if global_position.x > start_position.x + patrol_distance:
				direction = -1
				$Sprite2D.flip_h = true
				wait_timer = wait_time
				velocity.x = 0
				start_position.x += 1 
			elif global_position.x < start_position.x - patrol_distance:
				direction = 1
				$Sprite2D.flip_h = false
				wait_timer = wait_time
				velocity.x = 0
				start_position.x -= 1 
				
			# Если уперся в стену
			if is_on_wall():
				direction *= -1
				$Sprite2D.flip_h = direction < 0
				wait_timer = wait_time
				velocity.x = 0

	move_and_slide()

func take_damage(damage_amount: int, knockback_power: float = 500.0):
	hp -= damage_amount
	knockback_timer = 0.2
	print("Враг получил урон! Осталось HP: ", hp)
	
	# Откидывание убрано, так как физика врага может быть нарушена
	# Но если хочешь вернуть, раскомментируй код ниже:
	#if global_position.x > get_tree().get_first_node_in_group("player").global_position.x:
	#	velocity.x = knockback_power
	#else:
	#	velocity.x = -knockback_power

	if hp <= 0:
		queue_free()
