extends "res://components/ai/base/state.gd"

var is_dashing = false
var dash_timer = 0.0
var target_dir = 1
var locked_target_x = 0.0

func enter() -> void:
	var enemy = state_machine.parent
	
	locked_target_x = enemy.player_ref.global_position.x
	target_dir = 1 if locked_target_x > enemy.global_position.x else -1
	
	enemy.set_facing(target_dir)
	enemy.air_dash_cooldown_timer = enemy.air_dash_cooldown
	
	enemy.velocity.y = enemy.jump_velocity * 1.4
	enemy.velocity.x = target_dir * enemy.speed 
	
	is_dashing = false
	enemy.play_animation("chase")

func physics_update(delta: float) -> void:
	var enemy = state_machine.parent
	
	if not is_dashing:
		if not enemy.is_on_floor():
			enemy.velocity.y += enemy.gravity * delta
			
		var player_y = enemy.player_ref.global_position.y
		var enemy_y = enemy.global_position.y
		
		var target_y = player_y - 20.0 
		
		if (enemy_y <= target_y or enemy.velocity.y >= 0) and not enemy.is_on_floor():
			is_dashing = true
			enemy.velocity.y = 0 
			
			var dash_dir = sign(locked_target_x - enemy.global_position.x)
			if dash_dir == 0: dash_dir = target_dir
			
			enemy.velocity.x = dash_dir * 800.0 
			dash_timer = 0.3
			enemy.play_animation("reposition")
			
			if enemy.has_node("MeleeWeapon"):
				enemy.get_node("MeleeWeapon").attack()
				
			enemy.attack_cooldown_timer = enemy.attack_cooldown
		
		# Если приземлился раньше времени
		if enemy.is_on_floor():
			state_machine.transition_to(Entity.State.ALERT) # <--- ЖЕЛТЫЙ РЕЖИМ
			return
			
	else:
		dash_timer -= delta
		enemy.velocity.y = 0 
		
		var dist_to_target = abs(locked_target_x - enemy.global_position.x)
		
		# Конец дэша (врезался, время вышло, или долетел)
		if enemy.is_on_wall() or enemy.is_on_ceiling() or dash_timer <= 0.0 or dist_to_target < 20.0:
			is_dashing = false
			enemy.velocity.x = 0
			enemy.velocity.y = 200.0 # Начинаем падать
			state_machine.transition_to(Entity.State.ALERT) # <--- ЖЕЛТЫЙ РЕЖИМ
			return
