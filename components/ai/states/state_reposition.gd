extends "res://components/ai/base/state.gd"

var dash_timer = 0.0
var is_super_dashing = false
var is_jumping_back = false 
var original_dir_to_player = 0
const DASH_PAST_DISTANCE = 60.0 

func enter() -> void:
	var enemy = state_machine.parent
	dash_timer = 0.5 # Чуть больше времени на отступление
	is_super_dashing = false
	is_jumping_back = false
	
	# --- ФИКС: СТАВИМ КУЛДАУН СРАЗУ ПРИ ВХОДЕ ---
	enemy.reposition_cooldown_timer = 0.8 # Маленькая перезарядка (0.8 сек)
	# ---------------------------------------------
	
	var dir_to_player = sign(enemy.player_ref.global_position.x - enemy.global_position.x)
	if dir_to_player == 0:
		dir_to_player = enemy.direction
	original_dir_to_player = dir_to_player
	enemy.set_facing(int(dir_to_player))
	
	# УСИЛЕНИЕ: Отпрыгиваем дальше и быстрее
	enemy.velocity.x = -enemy.direction * enemy.reposition_speed * 1.5
	enemy.play_animation("reposition")

func physics_update(delta: float) -> void:
	var enemy = state_machine.parent
	
	# --- 1. ЛОГИКА ПРЫЖКА НАЗАД ---
	if is_jumping_back:
		enemy.velocity.x = -enemy.direction * enemy.reposition_speed * 2.0 # Усиленный прыжок
		
		if enemy.is_on_floor():
			is_jumping_back = false
			enemy.jump_cooldown_timer = 1.0
			state_machine.transition_to(Entity.State.CHASE)
		return

	# --- 2. ЛОГИКА СУПЕР-ДЭША ---
	if is_super_dashing:
		dash_timer -= delta
		enemy.velocity.y = 0
		
		var passed_distance = (enemy.global_position.x - enemy.player_ref.global_position.x) * original_dir_to_player
		
		if passed_distance > DASH_PAST_DISTANCE or dash_timer <= 0.0:
			is_super_dashing = false
			enemy.velocity.x = 0
			var target_dir = 1 if enemy.player_ref.global_position.x > enemy.global_position.x else -1
			enemy.set_facing(target_dir)
			state_machine.transition_to(Entity.State.ATTACK)
		return
		
	# --- 3. ОБЫЧНОЕ ОТСТУПЛЕНИЕ ---
	dash_timer -= delta
	enemy.velocity.x = move_toward(enemy.velocity.x, 0, enemy.reposition_decel * delta)
	
	var dist = enemy.global_position.distance_to(enemy.player_ref.global_position)
	
	# --- 4. ЗАГНАН В УГОЛ ---
	if enemy.is_on_wall() and dash_timer > 0.0:
		var choice = randi() % 2
		var wall_check = enemy.get_node("WallCheck")
		
		# ВАРИАНТ 1: Прыжок назад
		if choice == 0 and not wall_check.is_colliding():
			is_jumping_back = true
			enemy.velocity.y = enemy.jump_velocity
			enemy.velocity.x = -enemy.direction * enemy.reposition_speed * 2.0
			return
		else:
			# ВАРИАНТ 2: Супер-дэш
			is_super_dashing = true
			dash_timer = 0.3
			enemy.velocity.x = enemy.direction * enemy.reposition_speed * 2.5 # Усиленный дэш
			enemy.velocity.y = 0
			return

	# --- 5. ДОСТИГЛИ ДИСТАНЦИИ ИЛИ ТАЙМАУТ ---
	if dist >= enemy.attack_min_range:
		if enemy.attack_cooldown_timer > 0.0:
			state_machine.transition_to(Entity.State.CHASE)
		else:
			state_machine.transition_to(Entity.State.ATTACK)
		return
	
	if dash_timer <= 0.0:
		if enemy.attack_cooldown_timer > 0.0:
			state_machine.transition_to(Entity.State.CHASE)
		else:
			state_machine.transition_to(Entity.State.ATTACK)
