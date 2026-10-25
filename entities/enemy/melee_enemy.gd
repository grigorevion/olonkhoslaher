extends "res://entities/enemy/base_enemy.gd"

# --- НАСТРОЙКИ УМНОГО ИИ ---
@export var chase_speed = 250.0
@export var detection_radius = 500.0
@export var memory_time = 2.0
@export var alert_time = 0.5
@export var turn_delay = 0.3
@export var patrol_distance = 150.0

# --- ПЕРЕМЕННЫЕ ---
var state = "patrol" # patrol, alert, chase, return
var wait_timer = 0.0
var memory_timer = 0.0
var last_known_player_pos = Vector2.ZERO
var turn_timer = 0.0
var is_turning = false
var start_position = Vector2.ZERO

func _ready():
	super._ready() # Вызываем базу (гравитация, поиск игрока, здоровье)
	start_position = global_position
	direction = [-1, 1].pick_random()
	$Sprite2D.flip_h = direction < 0
	$CollisionShape2D.disabled = false

# Переопределяем поведение из базы
func _update_behavior(delta: float) -> void:
	# 1. ПАМЯТЬ
	if player_ref:
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

	# 2. СОСТОЯНИЯ
	if state == "patrol":
		$Sprite2D.modulate = Color(1, 1, 1) # Белый
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
		$Sprite2D.modulate = Color(1, 1, 0) # Желтый
		velocity.x = 0
		wait_timer -= delta
		if last_known_player_pos.x > global_position.x: $Sprite2D.flip_h = false
		else: $Sprite2D.flip_h = true
		if wait_timer <= 0.0: state = "chase"
				
	elif state == "chase":
		$Sprite2D.modulate = Color(1, 0.3, 0.3) # Красный
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
		$Sprite2D.modulate = Color(0.5, 0.5, 1) # Синий
		if start_position.x > global_position.x: direction = 1
		else: direction = -1
		velocity.x = direction * speed
		$Sprite2D.flip_h = direction < 0
		if abs(start_position.x - global_position.x) < 10.0:
			state = "patrol"
			wait_timer = 1.0
			turn_timer = 0.0
			is_turning = false
