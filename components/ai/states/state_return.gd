extends "res://components/ai/base/state.gd"

var start_position = Vector2.ZERO

func enter() -> void:
	state_machine.parent.play_animation("return")
	start_position = state_machine.parent.start_position

func physics_update(delta: float) -> void:
	var enemy = state_machine.parent
	
	if enemy.player_ref:
		var dist = enemy.global_position.distance_to(enemy.player_ref.global_position)
		if dist < enemy.detection_radius:
			state_machine.transition_to(Entity.State.ALERT)
			return
			
	var target_dir = 1 if start_position.x > enemy.global_position.x else -1
	enemy.set_facing(target_dir)
	
	enemy.velocity.x = enemy.direction * enemy.speed
	
	if abs(start_position.x - enemy.global_position.x) < 10.0:
		state_machine.transition_to(Entity.State.PATROL)
