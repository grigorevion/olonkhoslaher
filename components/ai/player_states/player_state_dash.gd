extends "res://components/ai/base/state.gd"

var dash_timer = 0.0

func enter() -> void:
	var player = state_machine.parent
	dash_timer = player.dash_duration
	
	# Включаем неуязвимость и невидимость
	player.get_node("HealthComponent").is_invulnerable = true
	player.is_stealthed = true
	player.play_animation("dash")
	
	# Задаем скорость рывка
	var dir = player.input_direction
	if dir == 0:
		dir = player.facing_direction # Если стоим — рывок вперед по взгляду
	player.set_facing(int(dir))
	player.velocity.x = dir * player.dash_speed
	player.velocity.y = 0 # Отключаем падение на время рывка

func physics_update(delta: float) -> void:
	var player = state_machine.parent
	dash_timer -= delta
	
	# Тормозим рывок
	player.velocity.x = move_toward(player.velocity.x, 0, player.speed * 4 * delta)
	
	if dash_timer <= 0.0:
		# Выключаем неуязвимость и невидимость
		player.get_node("HealthComponent").is_invulnerable = false
		player.is_stealthed = false
		player.dash_cooldown_timer = player.dash_cooldown
		
		# Возвращаемся в нужное состояние
		if player.is_on_floor():
			if player.input_direction != 0:
				state_machine.transition_to(Entity.State.RUN)
			else:
				state_machine.transition_to(Entity.State.IDLE)
		else:
			state_machine.transition_to(Entity.State.JUMP)
