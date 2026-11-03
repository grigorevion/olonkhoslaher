extends Node
class_name StatusEffectComponent

# Словарь для хранения активных статусов: {"invulnerable": 0.2, "stealth": 1.5}
var active_effects: Dictionary = {}

func _process(delta: float) -> void:
	# Тикаем таймеры всех активных эффектов
	for effect in active_effects.keys():
		active_effects[effect] -= delta
		if active_effects[effect] <= 0.0:
			active_effects.erase(effect) # Удаляем, когда время вышло

# Добавить эффект (например, add_effect("invulnerable", 0.2))
func add_effect(effect_name: String, duration: float) -> void:
	active_effects[effect_name] = duration

# Проверить, активен ли эффект (например, has_effect("invulnerable"))
func has_effect(effect_name: String) -> bool:
	return active_effects.has(effect_name)
