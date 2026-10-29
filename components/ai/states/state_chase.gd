extends "res://components/ai/base/state.gd"

var turn_timer = 0.0
var is_turning = false

func enter() -> void:
	state_machine.parent.play_animation("chase")
	turn_timer = 0.0
	is_turning = false
	var target_dir = 1 if state_machine.parent.player_ref.global_position.x > state_machine.parent.global_position.x else -1
	state_machine.parent.set_facing(target_dir)

func physics_update(delta: float) -> void:
	var enemy = state_machine.parent
	
	# Если игрок стал невидимым — теряем его (в удивление)
	if enemy.player_ref.is_stealthed:
		state_machine.transition_to(Entity.State.ALERT)
		return
		
	var target_x = enemy.player_ref.global_position.x
	var target_dir = 1 if target_x > enemy.global_position.x else -1
	var dist = enemy.global_position.distance_to(enemy.player_ref.global_position)
	
	if dist < enemy.attack_range:
		if dist < enemy.attack_min_range:
			state_machine.transition_to(Entity.State.REPOSITION)
			return
		if enemy.attack_cooldown_timer > 0.0:
			enemy.velocity.x = 0
			return
		state_machine.transition_to(Entity.State.ATTACK)
		return
	
	if dist > enemy.detection_radius * 1.5:
		state_machine.transition_to(Entity.State.ALERT)
		return
		
	if target_dir != enemy.direction and not is_turning:
		is_turning = true
		turn_timer = 0.3
		
	if is_turning:
		turn_timer -= delta
		enemy.velocity.x = 0
		if turn_timer <= 0.0:
			enemy.set_facing(target_dir)
			is_turning = false
	else:
		enemy.velocity.x = enemy.direction * enemy.chase_speed
