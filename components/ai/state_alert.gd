extends "res://components/ai/state.gd"

var wait_timer = 0.0

func enter() -> void:
	wait_timer = 0.5
	state_machine.parent.velocity.x = 0
	state_machine.parent.get_node("Sprite2D").modulate = Color(1, 1, 0) # Желтый

func physics_update(delta: float) -> void:
	wait_timer -= delta
	var enemy = state_machine.parent
	
	# Разворачиваемся в сторону игрока
	if enemy.player_ref.global_position.x > enemy.global_position.x:
		enemy.get_node("Sprite2D").flip_h = false
	else:
		enemy.get_node("Sprite2D").flip_h = true
		
	if wait_timer <= 0.0:
		state_machine.transition_to("chase")
