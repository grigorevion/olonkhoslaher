extends "res://components/ai/base/state.gd"

var turn_timer = 0.0
var is_turning = false

func enter() -> void:
	state_machine.parent.play_animation("chase")
	turn_timer = 0.0
	is_turning = false
	if is_instance_valid(state_machine.parent.player_ref):
		var target_dir = 1 if state_machine.parent.player_ref.global_position.x > state_machine.parent.global_position.x else -1
		state_machine.parent.set_facing(target_dir)

func physics_update(delta: float) -> void:
	var enemy = state_machine.parent
	
	if not is_instance_valid(enemy.player_ref):
		state_machine.transition_to(Entity.State.RETURN)
		return
		
	var player_stealth = enemy.player_ref.get_node("StatusEffectComponent").has_effect("stealth")
	if player_stealth:
		state_machine.transition_to(Entity.State.ALERT)
		return
		
	var target_x = enemy.player_ref.global_position.x
	var target_y = enemy.player_ref.global_position.y
	var target_dir = 1 if target_x > enemy.global_position.x else -1
	
	var dist = enemy.global_position.distance_to(enemy.player_ref.global_position)
	var y_diff = enemy.global_position.y - target_y 
	
	var is_ledge = false
	if enemy.has_node("LedgeCheck"):
		is_ledge = not enemy.get_node("LedgeCheck").is_colliding()
	
	if enemy.air_dash_cooldown_timer <= 0.0:
		if enemy.is_on_wall() and enemy.is_on_floor() and y_diff > 60.0:
			state_machine.transition_to(Entity.State.AIR_DASH_ATTACK)
			return
		elif enemy.is_on_floor() and y_diff < -40.0:
			if is_ledge or enemy.is_on_wall():
				state_machine.transition_to(Entity.State.GROUND_SLAM)
				return
	
	if dist < enemy.attack_range and abs(y_diff) < 60.0:
		if dist < enemy.attack_min_range and enemy.reposition_cooldown_timer <= 0.0:
			state_machine.transition_to(Entity.State.REPOSITION)
			return
		if enemy.attack_cooldown_timer > 0.0:
			enemy.velocity.x = 0
			return
			
		# --- РАНДОМ: 1 из 3 = Dash Combo, 2 из 3 = Обычная атака ---
		if randf() < 0.33:
			state_machine.transition_to(Entity.State.DASH_COMBO)
		else:
			state_machine.transition_to(Entity.State.ATTACK)
		# ------------------------------------------------------------
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
		
		if enemy.is_on_wall() and enemy.is_on_floor() and enemy.jump_cooldown_timer <= 0.0:
			var wall_check = enemy.get_node("WallCheck")
			if not wall_check.is_colliding():
				enemy.velocity.y = enemy.jump_velocity
				enemy.jump_cooldown_timer = 1.0
			else:
				enemy.velocity.x = 0
