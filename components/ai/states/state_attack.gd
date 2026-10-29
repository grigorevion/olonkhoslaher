extends "res://components/ai/base/state.gd"

var attack_timer = 0.0
var has_attacked = false

func enter() -> void:
	var enemy = state_machine.parent
	attack_timer = 0.5
	has_attacked = false
	enemy.velocity.x = 0
	
	var target_dir = 1 if enemy.player_ref.global_position.x > enemy.global_position.x else -1
	enemy.set_facing(target_dir)
		
	enemy.play_animation("attack")

func physics_update(delta: float) -> void:
	var enemy = state_machine.parent
	attack_timer -= delta
	
	enemy.velocity.x = 0
	
	if attack_timer <= 0.25 and not has_attacked:
		has_attacked = true
		if enemy.has_node("MeleeWeapon"):
			enemy.get_node("MeleeWeapon").attack()
			
	if attack_timer <= 0.0:
		enemy.attack_cooldown_timer = enemy.attack_cooldown
		state_machine.transition_to(Entity.State.CHASE)
