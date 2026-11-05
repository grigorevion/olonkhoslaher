extends "res://components/ai/base/state.gd"

var attack_timer = 0.0

func enter() -> void:
	var player = state_machine.parent
	attack_timer = player.attack_duration
	
	player.set_facing(player.facing_direction)
	player.velocity.x = player.facing_direction * player.attack_knockback
	
	if player.has_node("MeleeWeapon"):
		player.get_node("MeleeWeapon").attack()
		
	player.play_animation("attack")

# ЭТА ФУНКЦИЯ ВЫЗЫВАЕТСЯ АВТОМАТИЧЕСКИ ПРИ СМЕНЕ СОСТОЯНИЯ
func exit() -> void:
	var player = state_machine.parent
	# Отменяем визуал удара (если он еще идет)
	if player.has_node("MeleeWeapon"):
		player.get_node("MeleeWeapon").cancel_attack()

func physics_update(delta: float) -> void:
	var player = state_machine.parent
	
	# --- ОТМЕНА АТАКИ РЫВКОМ ---
	if player.input_dash_pressed and player.dash_cooldown_timer <= 0.0:
		state_machine.transition_to(Entity.State.DASH)
		return
	# -----------------------------
	
	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta
		
	player.velocity.x = move_toward(player.velocity.x, 0, player.speed * 4 * delta)
	
	attack_timer -= delta
	
	if attack_timer <= 0.0:
		player.play_animation("idle") 
		
		if player.is_on_floor():
			if player.input_direction != 0:
				state_machine.transition_to(Entity.State.RUN)
			else:
				state_machine.transition_to(Entity.State.IDLE)
		else:
			state_machine.transition_to(Entity.State.JUMP)
