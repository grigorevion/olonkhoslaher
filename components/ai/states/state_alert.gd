extends "res://components/ai/base/state.gd"

var wait_timer = 0.0

func enter() -> void:
	wait_timer = 0.5
	state_machine.parent.velocity.x = 0
	state_machine.parent.get_node("Sprite2D").modulate = Color(1, 1, 0) # Желтый

func physics_update(delta: float) -> void:
	wait_timer -= delta
	var enemy = state_machine.parent
	
	# Разворачиваемся в сторону игрока (если он есть)
	if enemy.player_ref:
		if enemy.player_ref.global_position.x > enemy.global_position.x:
			enemy.get_node("Sprite2D").flip_h = false
			enemy.direction = 1
		else:
			enemy.get_node("Sprite2D").flip_h = true
			enemy.direction = -1
	
	if wait_timer <= 0.0:
		# Проверяем, видим ли мы еще игрока
		if enemy.player_ref:
			var dist = enemy.global_position.distance_to(enemy.player_ref.global_position)
			if dist < enemy.detection_radius:
				state_machine.transition_to("chase") # Если видим — гонимся
			else:
				state_machine.transition_to("return") # Если не видим — идем домой
		else:
			state_machine.transition_to("return")
