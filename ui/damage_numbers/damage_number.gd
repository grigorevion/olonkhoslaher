extends Node2D

@onready var label = $Label

func setup(damage_amount: int, is_crit: bool = false):
	label.text = str(damage_amount)
	
	# Если критический удар — делаем цифру больше и краснее
	if is_crit:
		label.scale = Vector2(1.5, 1.5)
		label.modulate = Color(1, 0.2, 0.2)
	else:
		label.modulate = Color(1, 1, 1)
	
	# Анимация вылета
	var tween = create_tween()
	# Летит вверх и немного в случайную сторону
	var random_x = randf_range(-30, 30)
	tween.tween_property(self, "position", position + Vector2(random_x, -60), 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Плавно растворяется в конце
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.6).set_delay(0.3)
	
	# Удаляется после завершения
	tween.tween_callback(queue_free)
