extends "res://components/ai/base/state.gd"

var max_dash_time = 0.4
var dash_timer = 0.0

func enter() -> void:
	var enemy = state_machine.parent
	dash_timer = max_dash_time
	
	# Разворачиваемся к игроку
	var dir_to_player = sign(enemy.player_ref.global_position.x - enemy.global_position.x)
	if dir_to_player == 0:
		dir_to_player = enemy.direction
	enemy.set_facing(int(dir_to_player))
	
	# Отпрыгиваем назад
	enemy.velocity.x = -enemy.direction * enemy.reposition_speed
	enemy.play_animation("reposition")

func physics_update(delta: float) -> void:
	var enemy = state_machine.parent
	dash_timer -= delta
	
	# Плавно тормозим
	enemy.velocity.x = move_toward(enemy.velocity.x, 0, enemy.reposition_decel * delta)
	
	var dist = enemy.global_position.distance_to(enemy.player_ref.global_position)
	
	# Достигли безопасной дистанции
	if dist >= enemy.attack_min_range:
		# Если кулдаун еще не прошел, возвращаемся в погоню (там он будет ждать)
		if enemy.attack_cooldown_timer > 0.0:
			state_machine.transition_to(Entity.State.CHASE)
		else:
			state_machine.transition_to(Entity.State.ATTACK)
		return
	
	# Если застряли в стене или таймаут — атакуем
	if dash_timer <= 0.0:
		if enemy.attack_cooldown_timer > 0.0:
			state_machine.transition_to(Entity.State.CHASE)
		else:
			state_machine.transition_to(Entity.State.ATTACK)
