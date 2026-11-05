extends "res://components/ai/base/state.gd"

var is_dashing = false
var dash_timer = 0.0
var target_dir = 1

func enter() -> void:
	var enemy = state_machine.parent
	target_dir = 1 if enemy.player_ref.global_position.x > enemy.global_position.x else -1
	enemy.set_facing(target_dir)
	
	enemy.air_dash_cooldown_timer = enemy.air_dash_cooldown
	
	# УВЕЛИЧЕННЫЙ ПРЫЖОК (на 40% выше обычного)
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
		
		if enemy_y <= target_y or enemy.velocity.y >= 0:
			is_dashing = true
			enemy.velocity.y = 0 
			enemy.velocity.x = target_dir * 800.0 # <--- СКОРОСТЬ УМЕНЬШЕНА (было 1200.0)
			dash_timer = 0.3
			enemy.play_animation("reposition")
			
			if enemy.has_node("MeleeWeapon"):
				enemy.get_node("MeleeWeapon").attack()
		
		if enemy.is_on_floor():
			state_machine.transition_to(Entity.State.CHASE)
			return
			
	else:
		dash_timer -= delta
		enemy.velocity.y = 0 
		
		if enemy.is_on_wall() or dash_timer <= 0.0:
			is_dashing = false
			enemy.velocity.x = 0
			enemy.velocity.y = 200.0
			state_machine.transition_to(Entity.State.CHASE)
			return
