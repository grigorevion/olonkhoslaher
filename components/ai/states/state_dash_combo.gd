extends "res://components/ai/base/state.gd"

var combo_step = 1
var combo_timer = 0.0
var combo_hits_landed = 0
var attack_delay = 0.35 
var has_attacked = false
var dash_speed = 450.0 
var locked_direction = 1 # <--- ФИКСИРУЕМ НАПРАВЛЕНИЕ

func enter() -> void:
	var enemy = state_machine.parent
	combo_step = 1
	combo_hits_landed = 0
	combo_timer = 0.0
	has_attacked = false
	
	enemy.air_dash_cooldown_timer = enemy.air_dash_cooldown
	
	# --- ЗАПОМИНАЕМ НАПРАВЛЕНИЕ РАЗ И НАВСЕГДА ---
	locked_direction = 1 if enemy.player_ref.global_position.x > enemy.global_position.x else -1
	enemy.set_facing(locked_direction)
	# ------------------------------------------------
	
	enemy.velocity.x = locked_direction * dash_speed
	enemy.play_animation("chase")

func physics_update(delta: float) -> void:
	var enemy = state_machine.parent
	combo_timer += delta
	
	# --- ЖЕСТКО ДЕРЖИМ СКОРОСТЬ В ЗАДАННОМ НАПРАВЛЕНИИ ---
	# Никаких проверок на стены или прыжков, он просто давит массой
	enemy.velocity.x = locked_direction * dash_speed
	# -----------------------------------------------------
	
	if not has_attacked and combo_timer >= 0.15:
		has_attacked = true
		perform_hit(enemy)
		
	if combo_timer >= attack_delay:
		if combo_step < 3:
			combo_step += 1
			combo_timer = 0.0
			has_attacked = false
			
			# УБРАЛИ ПРОВЕРКУ target_dir. Он бьет строго туда, куда начал ехать.
			enemy.play_animation("attack")
		else:
			# Комбо закончилось
			if combo_hits_landed >= 3:
				var player = enemy.player_ref
				if player.has_node("StatusEffectComponent"):
					player.get_node("StatusEffectComponent").add_effect("stunned", 1.0)
					
			enemy.velocity.x = 0
			enemy.attack_cooldown_timer = enemy.attack_cooldown
			state_machine.transition_to(Entity.State.CHASE)

func perform_hit(enemy):
	var weapon = enemy.get_node_or_null("MeleeWeapon")
	if weapon and weapon.has_node("HitboxComponent"):
		var hitbox = weapon.get_node("HitboxComponent")
		
		if hitbox.hit_target.is_connected(_on_hit_landed):
			hitbox.hit_target.disconnect(_on_hit_landed)
		hitbox.hit_target.connect(_on_hit_landed)
		
		if combo_step == 3:
			hitbox.scale = Vector2(1.5, 1.5)
			weapon.attack(1.5)
		else:
			hitbox.scale = Vector2(1, 1)
			weapon.attack(1.0)

func _on_hit_landed(_target):
	combo_hits_landed += 1

func exit() -> void:
	var enemy = state_machine.parent
	if enemy.has_node("MeleeWeapon"):
		enemy.get_node("MeleeWeapon").cancel_attack()
		var hitbox = enemy.get_node("MeleeWeapon").get_node_or_null("HitboxComponent")
		if hitbox:
			hitbox.scale = Vector2(1, 1)
