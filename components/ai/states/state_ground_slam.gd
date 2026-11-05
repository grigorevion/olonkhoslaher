extends "res://components/ai/base/state.gd"

var is_slamming = false
var slam_timer = 0.0
var locked_target_x = 0.0 

func enter() -> void:
	var enemy = state_machine.parent
	is_slamming = false
	slam_timer = 0.5 
	
	enemy.air_dash_cooldown_timer = enemy.air_dash_cooldown
	
	var dir_to_player = sign(enemy.player_ref.global_position.x - enemy.global_position.x)
	if dir_to_player == 0: 
		dir_to_player = enemy.direction
	locked_target_x = enemy.player_ref.global_position.x + (dir_to_player * 50.0)
	
	enemy.velocity.y = enemy.jump_velocity * 1.2 
	enemy.velocity.x = dir_to_player * 300.0 
	enemy.play_animation("alert") 

func physics_update(delta: float) -> void:
	var enemy = state_machine.parent
	
	if not is_slamming:
		# Если враг приземлился ДО того как вышло время прыжка
		if enemy.is_on_floor():
			slam_timer = 0.0 
		else:
			enemy.velocity.y += enemy.gravity * delta
			
		slam_timer -= delta
		
		if enemy.is_on_wall():
			enemy.velocity.x = 0
		else:
			var dir_to_target = sign(locked_target_x - enemy.global_position.x)
			if dir_to_target != 0:
				enemy.velocity.x = dir_to_target * 500.0 
				if abs(locked_target_x - enemy.global_position.x) < 15.0:
					enemy.velocity.x = 0
			else:
				enemy.velocity.x = 0
		
		if slam_timer <= 0.0:
			is_slamming = true
			enemy.velocity.x = 0
			enemy.play_animation("attack") 
			
	else:
		enemy.velocity.y = 2500.0 
		
		if enemy.is_on_floor():
			# Ударная волна
			var shockwave = preload("res://components/combat/HitboxComponent.tscn").instantiate()
			get_tree().current_scene.add_child(shockwave) 
			shockwave.global_position = enemy.global_position + Vector2(0, 30)
			shockwave.owner_entity = enemy 
			
			var damage = 10
			var variance = 0.0
			if enemy.data:
				damage = enemy.data.attack_damage
				variance = enemy.data.damage_variance
				
			shockwave.activate(0.2, damage, variance, false)
			get_tree().create_timer(1.0).timeout.connect(shockwave.queue_free)
			
			if enemy.death_effect:
				var fx = enemy.death_effect.instantiate()
				fx.global_position = enemy.global_position
				get_tree().current_scene.call_deferred("add_child", fx)
				
			enemy.attack_cooldown_timer = enemy.attack_cooldown
			enemy.velocity.x = 0
			enemy.velocity.y = 0
			
			# --- ФИКС: ВМЕСТО ТАЙМЕРА ПЕРЕХОДИМ В ЖЕЛТЫЙ РЕЖИМ ---
			state_machine.transition_to(Entity.State.ALERT)
			# -------------------------------------------------------
			return
