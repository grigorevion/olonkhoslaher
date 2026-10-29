extends "res://components/ai/base/state.gd"

var start_position = Vector2.ZERO

func enter() -> void:
	state_machine.parent.get_node("Sprite2D").modulate = Color(0.5, 0.5, 1) # Синий
	start_position = state_machine.parent.start_position

func physics_update(_delta: float) -> void:
	var enemy = state_machine.parent
	
	# ПРОВЕРКА: если игрок снова рядом, прерываем возврат и начинаем погоню
	if enemy.player_ref:
		var dist = enemy.global_position.distance_to(enemy.player_ref.global_position)
		if dist < enemy.detection_radius:
			state_machine.transition_to("alert") # Сначала удивляемся, потом гонимся
			return
	
	if start_position.x > enemy.global_position.x:
		enemy.direction = 1
	else:
		enemy.direction = -1
		
	enemy.velocity.x = enemy.direction * enemy.speed
	enemy.get_node("Sprite2D").flip_h = enemy.direction < 0
	
	# Если дошли до дома — начинаем патрулировать
	if abs(start_position.x - enemy.global_position.x) < 10.0:
		state_machine.transition_to("patrol")
