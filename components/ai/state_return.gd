extends "res://components/ai/state.gd"

var start_position = Vector2.ZERO

func enter() -> void:
	state_machine.parent.get_node("Sprite2D").modulate = Color(0.5, 0.5, 1) # Синий
	start_position = state_machine.parent.start_position

func physics_update(delta: float) -> void:
	var enemy = state_machine.parent
	
	if start_position.x > enemy.global_position.x:
		enemy.direction = 1
	else:
		enemy.direction = -1
		
	enemy.velocity.x = enemy.direction * enemy.speed
	enemy.get_node("Sprite2D").flip_h = enemy.direction < 0
	
	# Если дошли до дома — начинаем патрулировать
	if abs(start_position.x - enemy.global_position.x) < 10.0:
		state_machine.transition_to("patrol")
