extends "res://components/ai/base/state.gd"

var start_position = Vector2.ZERO

func enter() -> void:
	state_machine.parent.play_animation("return")
	start_position = state_machine.parent.start_position

func physics_update(delta: float) -> void:
	var enemy = state_machine.parent
	
	if enemy.player_ref:
		var dist = enemy.global_position.distance_to(enemy.player_ref.global_position)
		if dist < enemy.detection_radius:
			state_machine.transition_to(Entity.State.ALERT)
			return
			
	var target_dir = 1 if start_position.x > enemy.global_position.x else -1
	enemy.set_facing(target_dir)
	
	enemy.velocity.x = enemy.direction * enemy.speed
	
	# --- НОВОЕ: УМНЫЙ ПРЫЖОК ПРИ ВОЗВРАТЕ ---
	if enemy.is_on_wall() and enemy.is_on_floor() and enemy.jump_cooldown_timer <= 0.0:
		var wall_check = enemy.get_node("WallCheck")
		if not wall_check.is_colliding():
			enemy.velocity.y = enemy.jump_velocity
			enemy.jump_cooldown_timer = 1.0 # Кулдаун, чтобы не спамил
		else:
			# Если стена слишком высокая, просто стоим (ждем)
			enemy.velocity.x = 0
	# ------------------------------------------

	if abs(start_position.x - enemy.global_position.x) < 10.0:
		state_machine.transition_to(Entity.State.PATROL)
