extends "res://components/ai/state.gd"

var wait_timer = 0.0
var direction = 1
var patrol_distance = 150.0
var start_position = Vector2.ZERO

# Вызывается при входе в это состояние (когда враг начинает патрулировать)
func enter() -> void:
	start_position = state_machine.parent.global_position
	direction = [-1, 1].pick_random()
	state_machine.parent.get_node("Sprite2D").flip_h = direction < 0
	wait_timer = 0.0

# Вызывается каждый кадр физики
func physics_update(delta: float) -> void:
	var enemy = state_machine.parent
	
	# Меняем цвет на белый (патруль)
	enemy.get_node("Sprite2D").modulate = Color(1, 1, 1)
	
	if wait_timer > 0.0:
		wait_timer -= delta
		enemy.velocity.x = 0
	else:
		enemy.velocity.x = direction * enemy.speed
		
		# Проверка краев
		if enemy.global_position.x > start_position.x + patrol_distance:
			direction = -1
			enemy.get_node("Sprite2D").flip_h = true
			wait_timer = randf_range(0.5, 1.5)
		elif enemy.global_position.x < start_position.x - patrol_distance:
			direction = 1
			enemy.get_node("Sprite2D").flip_h = false
			wait_timer = randf_range(0.5, 1.5)
			
		# Проверка стены
		if enemy.is_on_wall():
			direction *= -1
			enemy.get_node("Sprite2D").flip_h = direction < 0
