extends "res://components/ai/base/state.gd"

var wait_timer = 0.0

func enter() -> void:
	wait_timer = 0.5
	state_machine.parent.velocity.x = 0
	state_machine.parent.play_animation("alert")

func physics_update(delta: float) -> void:
	wait_timer -= delta
	var enemy = state_machine.parent
	
	if enemy.player_ref:
		var target_dir = 1 if enemy.player_ref.global_position.x > enemy.global_position.x else -1
		enemy.set_facing(target_dir)
	
	if wait_timer <= 0.0:
		if enemy.player_ref:
			var dist = enemy.global_position.distance_to(enemy.player_ref.global_position)
			if dist < enemy.attack_range:
				state_machine.transition_to(Entity.State.ATTACK)
			elif dist < enemy.detection_radius:
				state_machine.transition_to(Entity.State.CHASE)
			else:
				state_machine.transition_to(Entity.State.RETURN)
		else:
			state_machine.transition_to(Entity.State.RETURN)
