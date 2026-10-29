extends "res://components/ai/base/state.gd"

func enter() -> void:
	state_machine.parent.play_animation("jump")

func physics_update(delta: float) -> void:
	var player = state_machine.parent
	
	if player.input_dash_pressed and player.dash_cooldown_timer <= 0.0:
		state_machine.transition_to(Entity.State.DASH)
		return
		
	if player.velocity.y > 0:
		player.velocity.y += player.gravity * player.fall_multiplier * delta
		
	if player.input_direction != 0:
		player.set_facing(player.input_direction)
		player.velocity.x = player.input_direction * player.speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.speed * 4 * delta)
		
	if player.input_attack_pressed:
		state_machine.transition_to(Entity.State.ATTACK)
		return
		
	if player.jump_buffer_timer > 0.0 and player.coyote_timer > 0.0:
		player.velocity.y = player.jump_velocity
		player.jump_buffer_timer = 0.0
		player.coyote_timer = 0.0
		
	if player.is_on_floor():
		if player.input_direction != 0:
			state_machine.transition_to(Entity.State.RUN)
		else:
			state_machine.transition_to(Entity.State.IDLE)
