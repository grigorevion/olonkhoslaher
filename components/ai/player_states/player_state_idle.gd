extends "res://components/ai/base/state.gd"

func enter() -> void:
	state_machine.parent.velocity.x = 0
	state_machine.parent.set_facing(state_machine.parent.facing_direction)
	state_machine.parent.play_animation("idle")

func physics_update(delta: float) -> void:
	var player = state_machine.parent
	
	if player.input_dash_pressed and player.dash_cooldown_timer <= 0.0:
		state_machine.transition_to(Entity.State.DASH)
		return
		
	if player.jump_buffer_timer > 0.0 and player.coyote_timer > 0.0:
		player.velocity.y = player.jump_velocity
		player.jump_buffer_timer = 0.0
		player.coyote_timer = 0.0
		state_machine.transition_to(Entity.State.JUMP)
		return
		
	if player.input_attack_pressed:
		state_machine.transition_to(Entity.State.ATTACK)
	elif player.input_direction != 0:
		state_machine.transition_to(Entity.State.RUN)
	elif not player.is_on_floor():
		state_machine.transition_to(Entity.State.JUMP)
