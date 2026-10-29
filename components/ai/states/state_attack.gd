extends "res://components/ai/base/state.gd"

var attack_timer = 0.0
var has_attacked = false

func enter() -> void:
	var enemy = state_machine.parent
	attack_timer = 0.5 # Время на замах и удар
	has_attacked = false
	enemy.velocity.x = 0 # Останавливаемся для удара
	
	# Поворачиваемся к игроку
	if enemy.player_ref.global_position.x > enemy.global_position.x:
		enemy.get_node("Sprite2D").flip_h = false
		enemy.direction = 1
	else:
		enemy.get_node("Sprite2D").flip_h = true
		enemy.direction = -1
		
	# Меняем цвет на темно-красный (ярость)
	enemy.get_node("Sprite2D").modulate = Color(0.8, 0.1, 0.1)

func physics_update(delta: float) -> void:
	var enemy = state_machine.parent
	attack_timer -= delta
	
	# Наносим удар в середине анимации
	if attack_timer <= 0.25 and not has_attacked:
		has_attacked = true
		if enemy.has_node("HitboxComponent"):
			enemy.get_node("HitboxComponent").activate(0.1) # Включаем хитбокс на 0.1 сек
			
	if attack_timer <= 0.0:
		state_machine.transition_to("chase") # После удара снова бежим
