extends "res://components/ai/base/state.gd"

var dash_timer = 0.0

func enter() -> void:
	var player = state_machine.parent
	dash_timer = player.dash_duration
	
	# Вместо флагов используем статусы!
	var status_manager = player.get_node("StatusEffectComponent")
	status_manager.add_effect("invulnerable", player.dash_duration)
	status_manager.add_effect("stealth", player.dash_duration)
	
	player.play_animation("dash")
	
	var dir = player.input_direction
	if dir == 0:
		dir = player.facing_direction 
	player.set_facing(int(dir))
	
	player.velocity.x = dir * player.dash_speed
	player.velocity.y = 0 

func physics_update(delta: float) -> void:
	var player = state_machine.parent
	dash_timer -= delta
	
	player.velocity.x = move_toward(player.velocity.x, 0, player.speed * 4 * delta)
	
	if dash_timer <= 0.0:
		player.dash_cooldown_timer = player.dash_cooldown
		
		if player.is_on_floor():
			if player.input_direction != 0:
				state_machine.transition_to(Entity.State.RUN)
			else:
				state_machine.transition_to(Entity.State.IDLE)
		else:
			state_machine.transition_to(Entity.State.JUMP)
