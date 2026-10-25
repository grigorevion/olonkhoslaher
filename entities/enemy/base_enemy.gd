extends CharacterBody2D

# --- НАСТРОЙКИ ---
@export var speed = 150.0
@export var chase_speed = 250.0
@export var detection_radius = 500.0
@export var leash_distance = 800.0
@export var memory_time = 2.0
@export var gravity = 4000.0
@export var knockback_power = 500.0
@export var alert_time = 0.5
@export var turn_delay = 0.3

# --- ПЕРЕМЕННЫЕ ---
var direction = 1
var knockback_timer = 0.0
var wait_timer = 0.0
var patrol_distance = 150.0
var start_position = Vector2.ZERO

var state = "patrol"
var player_ref = null
var memory_timer = 0.0
var last_known_player_pos = Vector2.ZERO
var turn_timer = 0.0
var is_turning = false 

func _ready():
	start_position = global_position
	patrol_distance = randf_range(100.0, 200.0)
	direction = [-1, 1].pick_random()
	$Sprite2D.flip_h = direction < 0
	player_ref = get_tree().get_first_node_in_group("player")
	$CollisionShape2D.disabled = false
	
	# Подключаем компонент здоровья
	$HealthComponent.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if knockback_timer > 0.0:
		knockback_timer -= delta
		velocity.x = move_toward(velocity.x, 0, 1500 * delta)
		move_and_slide()
		return

	# 1. ОБНОВЛЕНИЕ ПАМЯТИ
	var dist_to_player = global_position.distance_to(player_ref.global_position)
	
	if dist_to_player < detection_radius:
		memory_timer = memory_time
		last_known_player_pos = player_ref.global_position
		
		if state == "patrol":
			state = "alert"
			wait_timer = alert_time
	else:
		memory_timer -= delta
		if memory_timer <= 0.0 and (state == "chase" or state == "alert"):
			state = "return"

	# 2. ДЕЙСТВИЯ
	if state == "patrol":
		$Sprite2D.modulate = Color(1, 1, 1)
		if wait_timer > 0.0:
			wait_timer -= delta
			velocity.x = 0
		else:
			velocity.x = direction * speed
			if global_position.x > start_position.x + patrol_distance:
				direction = -1
				$Sprite2D.flip_h = true
				wait_timer = randf_range(0.5, 1.5)
			elif global_position.x < start_position.x - patrol_distance:
				direction = 1
				$Sprite2D.flip_h = false
				wait_timer = randf_range(0.5, 1.5)
			if is_on_wall():
				direction *= -1
				$Sprite2D.flip_h = direction < 0

	elif state == "alert":
		$Sprite2D.modulate = Color(1, 1, 0)
		velocity.x = 0
		wait_timer -= delta
		
		if last_known_player_pos.x > global_position.x:
			$Sprite2D.flip_h = false
		else:
			$Sprite2D.flip_h = true
			
		if wait_timer <= 0.0:
			state = "chase"
				
	elif state == "chase":
		$Sprite2D.modulate = Color(1, 0.3, 0.3)
		
		var target_dir = 1 if last_known_player_pos.x > global_position.x else -1
		
		if target_dir != direction and not is_turning:
			is_turning = true
			turn_timer = turn_delay
			
		if is_turning:
			turn_timer -= delta
			velocity.x = 0
			if turn_timer <= 0.0:
				direction = target_dir
				$Sprite2D.flip_h = direction < 0
				is_turning = false
		else:
			velocity.x = direction * chase_speed
			
	elif state == "return":
		$Sprite2D.modulate = Color(0.5, 0.5, 1)
		if start_position.x > global_position.x:
			direction = 1
		else:
			direction = -1
			
		velocity.x = direction * speed
		$Sprite2D.flip_h = direction < 0
			
		if abs(start_position.x - global_position.x) < 10.0:
			state = "patrol"
			wait_timer = 1.0
			turn_timer = 0.0
			is_turning = false

	move_and_slide()

func take_damage(damage_amount: int, _knockback: float = 0.0):
	# Передаем урон в компонент здоровья
	$HealthComponent.take_damage(damage_amount)
	print("Враг получил урон! Осталось HP: ", $HealthComponent.current_hp)
	
	# Откидывание
	if global_position.x > player_ref.global_position.x:
		velocity.x = knockback_power
	else:
		velocity.x = -knockback_power
		
	knockback_timer = 0.2

func _on_died():
	print("Враг умер!")
	call_deferred("queue_free")

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(1)
