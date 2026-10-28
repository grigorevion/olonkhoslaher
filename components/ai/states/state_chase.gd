extends "res://components/ai/base/state.gd"

var turn_timer = 0.0
var is_turning = false

func enter() -> void:
	state_machine.parent.get_node("Sprite2D").modulate = Color(1, 0.3, 0.3) # Красный
	turn_timer = 0.0
	is_turning = false
	state_machine.parent.direction = 1 if state_machine.parent.player_ref.global_position.x > state_machine.parent.global_position.x else -1

func physics_update(delta: float) -> void:
	var enemy = state_machine.parent
	var target_x = enemy.player_ref.global_position.x
	var target_dir = 1 if target_x > enemy.global_position.x else -1
	
	# ГЛАВНАЯ ПРОВЕРКА: Если враг близко — АТАКУЕМ!
	if enemy.global_position.distance_to(enemy.player_ref.global_position) < 100.0:
		state_machine.transition_to("attack")
		return
	
	# Если игрок убежал слишком далеко, возвращаемся
	if enemy.global_position.distance_to(enemy.player_ref.global_position) < enemy.attack_range:
		state_machine.transition_to("alert")
		return
		
	if target_dir != enemy.direction and not is_turning:
		is_turning = true
		turn_timer = 0.3
		
	if is_turning:
		turn_timer -= delta
		enemy.velocity.x = 0
		if turn_timer <= 0.0:
			enemy.direction = target_dir
			enemy.get_node("Sprite2D").flip_h = enemy.direction < 0
			is_turning = false
	else:
		enemy.velocity.x = enemy.direction * enemy.chase_speed
