extends "res://components/ai/base/state.gd"

var wait_timer = 0.0
var direction = 1
var patrol_distance = 150.0
var start_position = Vector2.ZERO

func enter() -> void:
	start_position = state_machine.parent.global_position
	direction = [-1, 1].pick_random()
	state_machine.parent.get_node("Sprite2D").flip_h = direction < 0
	wait_timer = 0.0

func physics_update(delta: float) -> void:
	var enemy = state_machine.parent
	
	# --- ГЛАВНАЯ ПРОВЕРКА: УВИДЕЛ ЛИ ИГРОКА ---
	if enemy.player_ref:
		var dist = enemy.global_position.distance_to(enemy.player_ref.global_position)
		if dist < enemy.detection_radius:
			state_machine.transition_to("alert")
			return # Выходим, чтобы не делать лишнего в этот кадр
	
	# --- ПАТРУЛИРОВАНИЕ ---
	enemy.get_node("Sprite2D").modulate = Color(1, 1, 1) # Белый
	
	if wait_timer > 0.0:
		wait_timer -= delta
		enemy.velocity.x = 0
	else:
		enemy.velocity.x = direction * enemy.speed
		
		if enemy.global_position.x > start_position.x + patrol_distance:
			direction = -1
			enemy.get_node("Sprite2D").flip_h = true
			wait_timer = randf_range(0.5, 1.5)
		elif enemy.global_position.x < start_position.x - patrol_distance:
			direction = 1
			enemy.get_node("Sprite2D").flip_h = false
			wait_timer = randf_range(0.5, 1.5)
			
		if enemy.is_on_wall():
			direction *= -1
			enemy.get_node("Sprite2D").flip_h = direction < 0
